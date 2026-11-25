#!/usr/bin/env bash
#
# hypr-autoreload.sh — pause Hyprland's config autoreload while Claude edits hyprland.lua
#
# Hyprland reloads hyprland.lua every time the file is saved. Pausing that while an
# agent edits means Hyprland only ever loads the finished, syntax-checked config.
#
# This script is called by Claude Code hooks (see ../settings.json):
#
#   hypr-autoreload.sh pre     before each Edit / Write / MultiEdit / Bash call
#   hypr-autoreload.sh stop    when Claude finishes its turn, or the session ends
#
# "pre"  — if the call is about to change hyprland.lua, turn autoreload off.
# "stop" — turn autoreload back on, check the config for syntax errors,
#          and reload it once if it changed.
#
# Each Claude session that turned autoreload off leaves a marker file, so with two
# sessions open, autoreload stays off until both are done.

set -u

# --- Settings -------------------------------------------------------------------

CONFIG_FILE="$HOME/.config/hypr/hyprland.lua"

STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}/claude-hypr-autoreload"
SESSIONS_DIR="$STATE_DIR/sessions"        # one marker file per editing session
LAST_RELOAD_FILE="$STATE_DIR/last-reload" # its timestamp = when we last reloaded

# A marker not touched for this many minutes belongs to a session that crashed.
STALE_AFTER_MINUTES=360

# --- Hyprland helpers -----------------------------------------------------------

hyprland_is_running() {
    command -v hyprctl >/dev/null && [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]
}

turn_autoreload_off() {
    hyprctl eval 'hl.config({ misc = { disable_autoreload = true } })' >/dev/null 2>&1
}

turn_autoreload_on() {
    hyprctl eval 'hl.config({ misc = { disable_autoreload = false } })' >/dev/null 2>&1
}

reload_config() {
    # "config-only" skips re-applying the monitor layout
    hyprctl reload config-only >/dev/null 2>&1
}

# --- Reading the hook input -----------------------------------------------------
# Claude Code passes a JSON description of the tool call on stdin.

read_field() { # usage: read_field '.tool_input.file_path'
    jq -r "$1 // \"\"" <<<"$HOOK_INPUT"
}

is_about_to_edit_config() {
    local tool
    tool=$(read_field '.tool_name')

    case "$tool" in
    Edit | Write | MultiEdit)
        local file
        file=$(read_field '.tool_input.file_path')
        [ -n "$file" ] && same_file "$file" "$CONFIG_FILE"
        ;;
    Bash)
        # A shell command can't be inspected precisely, so any command that
        # mentions hyprland.lua counts (e.g. sed -i ... hyprland.lua).
        read_field '.tool_input.command' | grep -q 'hyprland\.lua'
        ;;
    *)
        return 1
        ;;
    esac
}

same_file() {
    [ "$(realpath -m -- "$1")" = "$(realpath -m -- "$2")" ]
}

# --- Session markers ------------------------------------------------------------

other_sessions_still_editing() {
    find "$SESSIONS_DIR" -type f -mmin -"$STALE_AFTER_MINUTES" 2>/dev/null | grep -q .
}

config_changed_since_last_reload() {
    [ ! -e "$LAST_RELOAD_FILE" ] || [ "$CONFIG_FILE" -nt "$LAST_RELOAD_FILE" ]
}

tell_user() { # shows a one-line message in Claude Code
    jq -n --arg message "$1" '{systemMessage: $message}'
}

# --- The two hook actions -------------------------------------------------------

on_before_tool() {
    is_about_to_edit_config || return 0

    mkdir -p "$SESSIONS_DIR"
    if [ ! -e "$SESSION_MARKER" ]; then
        turn_autoreload_off
    fi
    touch "$SESSION_MARKER" # refresh it, so a long session never looks stale
}

on_turn_end() {
    # Did this session turn autoreload off? If not, there's nothing to undo.
    [ -e "$SESSION_MARKER" ] || return 0
    rm -f "$SESSION_MARKER"

    if other_sessions_still_editing; then
        return 0 # leave autoreload off until they finish too
    fi
    rm -f "$SESSIONS_DIR"/* # clear markers left by crashed sessions

    turn_autoreload_on

    [ -f "$CONFIG_FILE" ] || return 0
    config_changed_since_last_reload || return 0

    local syntax_error
    if syntax_error=$(luac -p "$CONFIG_FILE" 2>&1); then
        reload_config
        touch "$LAST_RELOAD_FILE"
        tell_user "Hyprland: config reloaded once after the agent's edits (autoreload back on)."
    else
        tell_user "Hyprland: NOT reloaded - hyprland.lua has a syntax error: $syntax_error"
    fi
}

# --- Main -----------------------------------------------------------------------

hyprland_is_running || exit 0

HOOK_INPUT=$(cat)
SESSION_ID=$(read_field '.session_id')
SESSION_MARKER="$SESSIONS_DIR/${SESSION_ID:-unknown}"

case "${1:-}" in
pre) on_before_tool ;;
stop) on_turn_end ;;
*) echo "usage: $0 pre|stop  (reads the hook's JSON on stdin)" >&2 ;;
esac

exit 0
