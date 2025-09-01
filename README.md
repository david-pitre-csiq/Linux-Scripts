# ClamAV On-Access Scanner Installer

This repository contains an **all-in-one installer script** for setting up [ClamAV](https://www.clamav.net/) with **real-time (on-access) scanning** on Ubuntu Linux.
Testing working on Ubuntu 22.04, 24.04, and 25.04. Ensure you have at least 4GB of ram and ideally run an "apt update && apt full-upgrade -y" followed by a reboot before installing.

⚠️ **Warning:**  
By default, the script enables on-access scanning for **the entire filesystem (`/`)**.  
This can be heavy on performance and I/O. In production, you may want to restrict it to user data directories (e.g. `/home`, `/var/www`).

---

## 🚀 Features
- Installs ClamAV (`clamav`, `clamav-daemon`)  
- Updates virus definitions (`freshclam`)  
- Configures and enables the `clamav-daemon` service  
- Creates a systemd unit for **on-access scanning** using `fanotify`  
- Detects if a reboot is required after a kernel upgrade and schedules it automatically  

---

## 📦 Installation

Clone this repo and run the installer:

```bash
git clone https://github.com/<your-username>/<your-repo>.git
cd <your-repo>
chmod +x install_clamav_onaccess.sh
./install_clamav_onaccess.sh
