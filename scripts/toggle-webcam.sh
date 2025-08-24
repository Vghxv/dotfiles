#!/bin/bash

# Webcam USB ID from `v4l2-ctl` → usb-0000:00:14.0-3 → /sys/bus/usb/devices/1-3
DEVICE_ID="1-3"
DRIVER_PATH="/sys/bus/usb/drivers/usb"
DEVICE_PATH="/sys/bus/usb/devices/$DEVICE_ID"
NOTIFY_TITLE="Camera Status"
# Check if the webcam is currently bound (powered)
if [ -e "$DRIVER_PATH/$DEVICE_ID" ]; then
    echo "$DEVICE_ID" | sudo tee "$DRIVER_PATH/unbind" > /dev/null
else
    echo "$DEVICE_ID" | sudo tee "$DRIVER_PATH/bind" > /dev/null
fi

