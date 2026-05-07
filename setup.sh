#!/bin/bash
# ndy.onl - New Digital Yarn Thin Client Installer
# Automates the setup of the RDP Thin Client on a fresh Debian installation.

set -e

# 1. Check for root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (sudo bash setup.sh)"
   exit 1
fi

echo "Starting ndy Thin Client Setup..."

# 2. Detect Debian Version and Install Dependencies
DEBIAN_VERSION=$(cat /etc/debian_version | cut -d'.' -f1)
echo "Detected Debian Version: $DEBIAN_VERSION"

RDP_PKG="freerdp2-x11"
if [ "$DEBIAN_VERSION" -ge 13 ]; then
    RDP_PKG="freerdp3-x11"
    echo "Using FreeRDP 3 for Debian 13+"
else
    echo "Using FreeRDP 2 for Debian 12"
fi

echo "Installing dependencies..."
apt-get update
apt-get install -y $RDP_PKG lightdm lightdm-gtk-greeter x11-xserver-utils usbip psmisc curl git feh plymouth plymouth-themes zenity jq netcat-openbsd

# 3. Create rdpuser
if ! id "rdpuser" &>/dev/null; then
    echo "Creating rdpuser..."
    useradd -m -s /bin/bash rdpuser
fi

# 4. Copy Files
echo "Copying system files..."

# If run via curl (late_command), we might need to clone the repo first to get the assets
if [ ! -d "usr" ] && [ ! -d "etc" ]; then
    echo "Downloading assets from GitHub..."
    cd /tmp
    git clone https://github.com/ndy-onl/RDP-Thin-Client.git rdp-tmp
    cd rdp-tmp
fi

# Copying binaries and configs
cp -v usr/local/bin/* /usr/local/bin/
mkdir -p /etc/lightdm
cp -v etc/lightdm/* /etc/lightdm/
mkdir -p /etc/rdp-client
cp -v etc/rdp-client/* /etc/rdp-client/
mkdir -p /usr/share/xsessions
cp -v usr/share/xsessions/* /usr/share/xsessions/

# Services & Rules (NEW)
echo "Installing background services and udev rules..."
mkdir -p /etc/systemd/system
cp -v etc/systemd/system/rdp-*.service /etc/systemd/system/
mkdir -p /etc/udev/rules.d
cp -v etc/udev/rules.d/99-freerdp-usb.rules /etc/udev/rules.d/

# Branding - Application & Logo Script
mkdir -p /usr/local/share/branding
cp -rv usr/local/share/branding/* /usr/local/share/branding/
mkdir -p /etc/X11/Xsession.d
cp -v etc/X11/Xsession.d/99set-logo /etc/X11/Xsession.d/

# Branding - Plymouth
echo "Configuring Plymouth theme..."
mkdir -p /usr/share/plymouth/themes
cp -rv usr/share/plymouth/themes/custom-spinner-nologos /usr/share/plymouth/themes/
plymouth-set-default-theme custom-spinner-nologos
update-initramfs -u

# Branding - Grub
echo "Configuring Grub branding..."
mkdir -p /boot/grub
cp -v boot/grub/custom-logo.png /boot/grub/
if grep -q "GRUB_BACKGROUND" /etc/default/grub; then
    sed -i 's|^#\?GRUB_BACKGROUND=.*|GRUB_BACKGROUND="/boot/grub/custom-logo.png"|' /etc/default/grub
else
    echo 'GRUB_BACKGROUND="/boot/grub/custom-logo.png"' >> /etc/default/grub
fi
update-grub

# 5. Set Permissions
echo "Setting permissions..."
chmod +x /usr/local/bin/rdp-*
chmod +x /usr/local/bin/improved-rdp-client
chmod +x /etc/X11/Xsession.d/99set-logo

# Ensure rdpuser owns their home and config
chown -R rdpuser:rdpuser /home/rdpuser
chown -R rdpuser:rdpuser /etc/rdp-client

# 6. Enable Services
echo "Enabling Services..."
systemctl enable lightdm
systemctl enable rdp-autologin.service
systemctl enable rdp-network-monitor.service
systemctl enable rdp-usb-redirect.service
systemctl enable rdp-client-optimize.service
systemctl enable rdp-fix-permissions.service
systemctl set-default graphical.target

echo "********************************************************"
echo "ndy Thin Client Setup complete."
echo ""
echo "Please reboot the system now."
echo "********************************************************"
