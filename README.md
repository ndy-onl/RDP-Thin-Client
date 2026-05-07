# ndy.onl - New Digital Yarn RDP Thin Client (Debian 12/13 Mod)

This project transforms a minimal Debian installation into a dedicated **Remote Desktop (RDP) Thin Client**. It is designed to boot directly into a full-screen RDP session with automatic login, high performance, and USB redirection support.

## 🚀 Features
- **Direct Boot to RDP:** Bypasses the standard desktop environment; logs directly into the RDP session.
- **Debian 12 & 13 Support:** Automatically detects the OS version and installs the correct FreeRDP (v2 or v3) packages.
- **Fail-Safe Startup:** Integrated loop ensures the RDP session restarts automatically if disconnected.
- **USB Redirection:** Dynamic monitoring and redirection of USB devices to the remote host.
- **Optimized for Performance:** Pre-configured with settings for low-latency and high-resolution (up to 4K) support.
- **Easy Deployment:** Install via a single setup script or a Debian package.

## 🛠 Installation

### Option 1: Using the Setup Script (Recommended)
1. Install a minimal Debian (Netinst) without a desktop environment.
2. Clone this repository or copy the files to the machine.
3. Run the installer as root:
   ```bash
   sudo bash setup.sh
   ```
4. Reboot the system.

### Option 2: Using the Debian Package
If you have built the `.deb` package:
```bash
sudo apt install ./ndy-thin-client.deb
```

## ⚙️ Configuration
The system configuration is stored in `/etc/rdp-client/config`. 

**Example Content:**
```bash
SERVER=your.rdp-server.address
DOMAIN=YOURDOMAIN
USERNAME=your_username
PASSWORD=your_password
USB_REDIRECTION=true
IGNORE_CERTIFICATE=true
AUTO_RECONNECT=true
```

## 📂 Project Structure
- `setup.sh`: Automated installer for fresh systems.
- `boot/`: Grub bootloader branding and background images.
- `etc/`: Configuration files for LightDM, X11, and the RDP client.
- `usr/`: System binaries (`improved-rdp-client`), desktop entries, and branding assets.
- `preseed.cfg`: Template for fully automated "One-Touch" Debian installations.
- `TECHNICAL_DOCS.md`: Detailed architecture, startup chain, and branding documentation.

## 📖 Documentation
For more detailed information on the system architecture, USB redirection logic, and branding asset management, please refer to [TECHNICAL_DOCS.md](TECHNICAL_DOCS.md).

## ⌨️ Hotkeys
- **F8:** Open RDP settings/diagnostics (if configured).
- **Ctrl+Alt+Enter:** Toggle Fullscreen mode.
- **Ctrl+Alt+F2:** Switch to a terminal console (for maintenance).
- **Ctrl+Alt+F7:** Switch back to the graphical RDP session.

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

**Note:** All logos, icons, and brand assets of ndy.onl (New Digital Yarn) are excluded from the MIT License and remain the intellectual property of ndy.onl.

---
*Maintained by ndy.onl - New Digital Yarn.*
