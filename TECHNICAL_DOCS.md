# Technical Documentation: ndy Thin Client Architecture

This document describes the internal workings and the "Startup-Chain" of the ndy RDP Thin Client.

## 1. Startup Chain (Boot to Session)

1.  **System Boot:** Debian starts and reaches the `graphical.target`.
2.  **LightDM Initialization:** The Display Manager starts. It is configured (`/etc/lightdm/lightdm.conf`) to:
    *   Run `/usr/local/bin/rdp-display-setup` (Pre-session script).
    *   Automatically log in the user `rdpuser`.
3.  **Session Launch:** LightDM looks for XSession files in `/usr/share/xsessions/`. It finds `rdp-autologin.desktop`, which points to the main launcher.
4.  **Main Launcher (`improved-rdp-client`):** 
    *   Loads config from `/etc/rdp-client/config`.
    *   Waits for the X-Server to be ready.
    *   Enters an infinite loop.
    *   Starts `xfreerdp` with optimized parameters.
    *   If `xfreerdp` exits (crash or disconnect), it waits 5 seconds and restarts the session.

## 2. Background Services (Systemd)

The stability of the client is maintained by several background services:
- **`rdp-autologin.service`**: The primary session launcher.
- **`rdp-network-monitor.service`**: Monitors connectivity and restarts the RDP session if the network drops.
- **`rdp-usb-redirect.service`**: Handles dynamic USB device detection and redirection.
- **`rdp-client-optimize.service`**: Disables heavy services (Bluetooth, CUPS, Avahi) to maximize performance.
- **`rdp-fix-permissions.service`**: Ensures correct ownership of `/etc/rdp-client` on every boot.

## 3. USB Redirection Logic

Dynamic USB mapping is handled via:
1.  **Udev Rule (`/etc/udev/rules.d/99-freerdp-usb.rules`)**: Grants the `plugdev` group access to USB devices.
2.  **`rdp-usb-redirect` script**:
    - It uses `udevadm monitor` to listen for "add" events.
    - When a device is plugged in, it extracts the VendorID and ProductID.
    - It identifies the PID of the active `xfreerdp` process.
    - It calls `xfreerdp-cli` to inject the device into the running session without needing a restart.

## 4. Display Configuration

The `rdp-display-setup` script ensures:
- The mouse cursor is set to a standard arrow (instead of the default X).
- A solid background color is applied to avoid flickering during transitions.
- Monitor resolutions are correctly detected (crucial for multi-monitor setups).

## 4. Maintenance and Debugging

- **Logs:** 
    - Main Loop: `/tmp/rdp-run.log`
    - USB Redirect: `/var/log/rdp-client/usb-redirect.log`
    - System Logs: `journalctl -u lightdm`
- **Shell Access:** Use `Ctrl+Alt+F2` to exit the graphical session and access the bash prompt for troubleshooting.
- **Manual Restart:** `sudo systemctl restart lightdm` will re-trigger the entire startup chain.

## 5. Branding & Assets

The thin client uses a set of specific assets to maintain a professional "ndy.onl" appearance across all phases of operation.

### 5.1 Asset Locations
- **Plymouth Theme:** `/usr/share/plymouth/themes/custom-spinner-nologos/`
- **Application Logos:** `/usr/local/share/branding/`
- **Grub/Boot Logos:** `/boot/grub/`

### 5.2 Asset Breakdown
- **`logo-login.png`**: The primary branding element. Used as the main logo in the Plymouth boot theme, as the window icon (`--window-icon`) for all Zenity dialogs in the RDP scripts, and as an overlay during session initialization.
- **`logo-boot.png` / `Logo-boot-high.png`**: Secondary assets for the boot phase. `Logo-boot-high.png` is optimized for high-resolution displays.
- **`output_wallpaper.png`**: A prepared 1920x1080 wallpaper asset. While the system defaults to a solid "Midnight Blue" to minimize flicker, this asset is available for desktop background deployment.
- **`logo-login-compat.png`**: A compatibility version of the main logo used by legacy Zenity calls to ensure consistent icon rendering across different library versions.

## 6. Service vs. UI Architecture

A key architectural decision in the final version is the separation of the boot/login service and the user interface:

- **LightDM (The Engine):** Still functions as the system's Display Manager. Its primary role is to initialize the X-Server and perform the **automatic login** of `rdpuser`.
- **Zenity (The Interface):** Since autologin is active, the standard LightDM "Greeter" (login screen) is never seen. Instead, **Zenity** handles all user interaction. This includes the HTML-based configuration UI (`rdp-settings`), error dialogs, and connection status updates.

This combination allows for a "headless" boot experience that transitions seamlessly into a custom, branded GUI.

---
*Technical Wiki for ndy.onl Thin Client Architecture.*
