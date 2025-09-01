#!/usr/bin/env bash
#
# install_clamav_onaccess.sh
#
# Installs ClamAV on Ubuntu and enables real-time (on-access) scanning.
# This config enables scanning for ALL filesystem access (/).
# For production, consider limiting to specific directories.
#

set -e

echo "[*] Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Check if a reboot is required (Ubuntu writes /var/run/reboot-required)
REBOOT_REQUIRED=false
if [ -f /var/run/reboot-required ]; then
    REBOOT_REQUIRED=true
fi

echo "[*] Installing ClamAV and daemon..."
sudo apt install -y clamav clamav-daemon curl

echo "[*] Stopping freshclam to update signatures..."
sudo systemctl stop clamav-freshclam || true

echo "[*] Updating virus signatures..."
sudo freshclam

echo "[*] Restarting freshclam..."
sudo systemctl enable clamav-freshclam
sudo systemctl start clamav-freshclam

echo "[*] Enabling ClamAV daemon..."
sudo systemctl enable clamav-daemon
sudo systemctl start clamav-daemon

echo "[*] Creating systemd service for on-access scanning..."
cat << 'EOF' | sudo tee /etc/systemd/system/clamav-onaccess.service > /dev/null
[Unit]
Description=ClamAV On-Access Scanner
Requires=clamav-daemon.service
After=clamav-daemon.service

[Service]
ExecStart=/usr/bin/clamdscan --fdpass --on-access=yes --recursive /
Restart=on-failure
User=root

[Install]
WantedBy=multi-user.target
EOF

echo "[*] Reloading systemd and enabling on-access scanner..."
sudo systemctl daemon-reexec
sudo systemctl enable clamav-onaccess
sudo systemctl start clamav-onaccess

echo "[*] Installation complete."
echo "    - ClamAV is installed and running"
echo "    - Real-time on-access scanning is enabled (all filesystem access)"
echo ""
echo "Test detection with:"
echo "    curl -o ~/eicar.com.txt https://secure.eicar.org/eicar.com.txt"
echo "Logs can be viewed with:"
echo "    journalctl -u clamav-onaccess -f"

# Handle reboot if required
if [ "$REBOOT_REQUIRED" = true ]; then
    echo ""
    echo "[!] A system reboot is required to load the new kernel."
    echo "[*] Scheduling reboot in 1 minute..."
    sudo shutdown -r +1 "Rebooting to complete ClamAV installation and kernel upgrade"
else
    echo ""
    echo "[*] No reboot required. You're good to go!"
fi
