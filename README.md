# Google Drive Sync in Linux Script v3.1

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![GitHub followers](https://img.shields.io/github/followers/ugurakcil?label=Follow&style=social)
![GitHub stars](https://img.shields.io/github/stars/ugurakcil?style=social)

## Author

**Uğur AKÇIL**

- [GitHub Profile](https://github.com/ugurakcil)
- [Website](https://www.datasins.com) en
- [Website](https://www.ugurakcil.com) tr
- [Instagram](https://instagram.com/datasins)

## Description

UBUNTU/LINUX GOOGLE DRIVE SYNCHRONIZATION SCRIPT

This script uses `rclone` and `inotifywait` to synchronize specified folders between a local Ubuntu 22.04 system and Google Drive. It performs an initial sync and then monitors the folders for changes, synchronizing any changes with Google Drive in real-time.

## Prerequisites

- Ubuntu 22.04
- `rclone` installed and configured
- `inotify-tools` installed

## Installation

### Step 1: Install rclone

Follow the official [rclone installation guide](https://rclone.org/install/) to install rclone.

### Step 2: Configure rclone

Run the following command to configure rclone for Google Drive:

```sh
rclone config
```

Follow the prompts to set up a new remote named gdrive (or any name you prefer).

If you are worried about making a mistake, you can search in detail on the internet for how to configure Google Drive with rclone.

### Step 3: Clone this Repository
Clone this repository to your local machine:

```sh
git clone https://github.com/ugurakcil/ubuntu-gdrive-sync.git
cd ubuntu-gdrive-sync
```

### Step 4: Configure the Script
Edit the script gdrive_sync.sh with your preferred text editor and update the following variables:

USER: Your Ubuntu username
GROUP: Your Ubuntu group
REMOTE: Your rclone remote name (default is gdrive)
LOCAL_DIR: The local directory where you want the Google Drive folders to be synchronized
FOLDERS: The names of the folders you want to synchronize

### Step 5: Make the Script Executable
Make the script executable with the following command:

```sh
chmod +x gdrive_sync.sh
```

Step 5: Running the Script as a Service
To ensure the script runs continuously, even after rebooting your system, you can set it up as a systemd service.

```sh
sudo nano /etc/systemd/system/gdrive_sync.service
```

Add the following content to the file:

```ini
[Unit]
Description=Google Drive Synchronization Service
After=network.target

[Service]
User=your_username
Group=your_group
ExecStart=/path/to/your/script/gdrive_sync.sh
Restart=always

[Install]
WantedBy=multi-user.target
```

Enable the service to start on boot and start the service immediately:

```sh
sudo systemctl daemon-reload
sudo systemctl enable gdrive_sync.service
sudo systemctl start gdrive_sync.service
sudo systemctl status gdrive_sync.service
```



