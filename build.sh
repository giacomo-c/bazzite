#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y \
    wireshark \
    nmap \
    kvantum \
    qt6-qtwebsockets-devel \

# install powerpanel for CyberPower UPS
dnf5 install -y https://dl4jz3rbrsfum.cloudfront.net/software/PPL_64bit_v1.4.1.rpm

# install latest rclone
dnf remove -y rclone
dnf install -y https://downloads.rclone.org/rclone-current-linux-amd64.rpm

# https://rclone.org/commands/rclone_mount/#rclone-as-unix-mount-helper
ln -rs /usr/bin/rclone /sbin/mount.rclone
ln -rs /usr/bin/rclone /usr/bin/rclonefs

# Install Heroic from Github release
HEROIC_GH_URL="https://api.github.com/repos/Heroic-Games-Launcher/HeroicGamesLauncher/releases/latest"
HEROIC_RPM_URL="curl -sSL "$HEROIC_GH_URL" | jq -r '.assets[] | select(.name | endswith(".rpm")) | .browser_download_url'"

if [[ -z "HEROIC_RPM_URL" ]]; then
    echo "Could not find the Heroic .rpm in latest releases." >&2
    exit 1
fi

dnf install -y "$HEROIC_RPM_URL"


# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

# Clean-up
rm -rf /tmp/* || true
find /var/* -maxdepth 0 -type d \! -name cache -exec rm -fr {} \;
find /var/cache/* -maxdepth 0 -type d \! -name libdnf5 \! -name rpm-ostree -exec rm -fr {} \;

#### Example for enabling a System Unit File

systemctl enable podman.socket
systemctl enable pwrstatd.service
