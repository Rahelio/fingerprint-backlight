# fingerprint-backlight

Flickers your keyboard backlight while your fingerprint scanner is waiting for a finger press.

Works on any Linux system with a keyboard backlight exposed via `/sys/class/leds/` (ThinkPad, ASUS, Dell, Chromebook, and others).

## Requirements

- Linux with systemd
- A fingerprint reader managed by [fprintd](https://fprint.freedesktop.org/)
- A keyboard with backlight support

The installer will check for and offer to install missing dependencies (`fprintd`, `brightnessctl`, `gdbus`).

## Install

```bash
git clone https://github.com/YOUR_USERNAME/fingerprint-backlight
cd fingerprint-backlight
bash install.sh
```

Test it:

```bash
fprintd-verify
```

## Uninstall

```bash
bash uninstall.sh
```

## How it works

A systemd user service runs at login and monitors the `net.reactivated.Fprint` D-Bus interface. When fprintd emits `VerifyFingerSelected` (scanner is ready and waiting), a flicker loop starts. It stops as soon as `VerifyStatus` fires (match or no-match). The backlight always restores to its original level.

## Tuning

Edit `~/.local/bin/fingerprint-backlight-flicker` and adjust:

```bash
FLICKER_DELAY=0.12   # seconds between on/off (lower = faster)
```

After editing, restart the service:

```bash
systemctl --user restart fingerprint-backlight-flicker.service
```

## Troubleshooting

**Backlight doesn't flicker:**
Check the service logs:
```bash
journalctl --user -u fingerprint-backlight-flicker.service -f
```

**No keyboard backlight found:**
Your hardware may not expose a backlight via `/sys/class/leds/`. Check with:
```bash
ls /sys/class/leds/
```

**fprintd not detecting signals:**
Make sure your fingerprint reader is enrolled:
```bash
fprintd-list "$USER"
```
