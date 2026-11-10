#!/bin/bash

BIN_DIR="$HOME/.local/bin"
SERVICE_DIR="$HOME/.config/systemd/user"

systemctl --user disable --now fingerprint-backlight-flicker.service 2>/dev/null && echo "✓ Service stopped and disabled"
rm -f "$SERVICE_DIR/fingerprint-backlight-flicker.service" && echo "✓ Service file removed"
rm -f "$BIN_DIR/fingerprint-backlight-flicker" && echo "✓ Script removed"
systemctl --user daemon-reload

echo "Done."
