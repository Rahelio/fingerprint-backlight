#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"
SERVICE_DIR="$HOME/.config/systemd/user"

# ── Helpers ──────────────────────────────────────────────────────────────────

info()  { echo "  $*"; }
ok()    { echo "✓ $*"; }
warn()  { echo "! $*"; }
die()   { echo "✗ $*" >&2; exit 1; }

check_dep() {
    command -v "$1" &>/dev/null
}

install_pkg() {
    local pkg="$1"
    if check_dep pacman;  then sudo pacman -S --noconfirm "$pkg"
    elif check_dep apt;   then sudo apt install -y "$pkg"
    elif check_dep dnf;   then sudo dnf install -y "$pkg"
    elif check_dep zypper; then sudo zypper install -y "$pkg"
    else die "Could not detect package manager. Please install '$pkg' manually."
    fi
}

# ── Checks ───────────────────────────────────────────────────────────────────

echo
echo "fingerprint-backlight installer"
echo "────────────────────────────────"

# systemd
check_dep systemctl || die "systemd is required but not found."

# fprintd
if check_dep fprintd; then
    ok "fprintd found"
else
    warn "fprintd not found — installing..."
    install_pkg fprintd
fi

# gdbus (glib2 / glib2-tools)
if check_dep gdbus; then
    ok "gdbus found"
else
    warn "gdbus not found — installing glib2-tools..."
    if check_dep pacman; then install_pkg glib2
    elif check_dep apt;  then install_pkg libglib2.0-bin
    elif check_dep dnf;  then install_pkg glib2
    else install_pkg glib2-tools
    fi
fi

# brightnessctl (preferred; falls back to direct sysfs write)
if check_dep brightnessctl; then
    ok "brightnessctl found"
else
    warn "brightnessctl not found — installing..."
    install_pkg brightnessctl || warn "Could not install brightnessctl; will try direct sysfs write (may need udev rule)."
fi

# keyboard backlight
BACKLIGHT=$(ls /sys/class/leds/*kbd_backlight*/brightness 2>/dev/null | head -1)
if [[ -n "$BACKLIGHT" ]]; then
    ok "Keyboard backlight detected: $(dirname "$BACKLIGHT" | xargs basename)"
else
    die "No keyboard backlight found in /sys/class/leds/. Your hardware may not support this."
fi

# ── Install ───────────────────────────────────────────────────────────────────

mkdir -p "$BIN_DIR" "$SERVICE_DIR"

cp "$SCRIPT_DIR/fingerprint-backlight-flicker" "$BIN_DIR/fingerprint-backlight-flicker"
chmod +x "$BIN_DIR/fingerprint-backlight-flicker"
ok "Script installed to $BIN_DIR/fingerprint-backlight-flicker"

cp "$SCRIPT_DIR/fingerprint-backlight-flicker.service" "$SERVICE_DIR/fingerprint-backlight-flicker.service"
ok "Service installed to $SERVICE_DIR"

systemctl --user daemon-reload
systemctl --user enable --now fingerprint-backlight-flicker.service
ok "Service enabled and started"

echo
echo "Done. Your keyboard backlight will now flicker when the fingerprint scanner needs your finger."
echo "To test: fprintd-verify"
echo "To remove: bash uninstall.sh"
