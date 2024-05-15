#!/bin/bash

############# Auto Google Drive Sync in Linux V3.1 #############

# Author: Uğur AKÇIL
# GitHub: https://github.com/ugurakcil
# Website: https://www.datasins.com
# Instagram: https://instagram.com/datasins

############################### DESCRIPTION ###############################

# This script uses rclone and inotifywait to synchronize specified
# folders between a local Ubuntu 22.04 system and Google Drive. It performs an
# initial sync and then monitors the folders for changes, synchronizing any changes
# with Google Drive in real-time.

############################## CONFIGURATIONS ##############################

# Change with your Ubuntu username
USER="zd" 

# Change with your Ubuntu group
GROUP="zd"

# Change with your rclone config name
REMOTE="gdrive"

# The local folder path where you want the Google Drive folders to be extracted
LOCAL_DIR="/home/zd/Desktop"

# Change the names of the folders you want pulled from your Google Drive
FOLDERS=("Academy" "Bash" "Backups" "Company" "Design" "Medias" "Mixed") 

################################# LICENSE #################################

# MIT License
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

############################################################################

# Log file name and path. You don't need to change
LOG_FILE="/var/log/rclone_sync.log"

USER_ID=$(id -u $USER)
GROUP_ID=$(id -g $GROUP)

ensure_dependencies() {
    if ! command -v inotifywait &>/dev/null; then
        echo "Installing inotify-tools..." | tee -a "$LOG_FILE"
        sudo apt-get update && sudo apt-get install -y inotify-tools | tee -a "$LOG_FILE"
    fi

    if ! command -v rclone &>/dev/null; then
        echo "rclone is required. Please install and configure rclone." | tee -a "$LOG_FILE"
        exit 1
    fi
}

setup_log_file() {
    if [ ! -f "$LOG_FILE" ]; then
        touch "$LOG_FILE"
        chown $USER_ID:$GROUP_ID "$LOG_FILE"
        chmod 644 "$LOG_FILE"
    fi
}

initial_sync() {
    for folder in "${FOLDERS[@]}"; do
        mkdir -p "$LOCAL_DIR/$folder"
        echo "Performing initial pull for $folder..." | tee -a "$LOG_FILE"
        if ! rclone copy "$REMOTE:$folder" "$LOCAL_DIR/$folder" --update --verbose --log-file="$LOG_FILE"; then
            echo "Error: Synchronization failed for $folder. Check logs: $LOG_FILE" | tee -a "$LOG_FILE"
        else
            adjust_permissions "$folder"
        fi
    done
}

adjust_permissions() {
    local folder=$1
    echo "Adjusting permissions for $folder..." | tee -a "$LOG_FILE"
    chown -R $USER_ID:$GROUP_ID "$LOCAL_DIR/$folder"
    chmod -R u+rwX,go+rX "$LOCAL_DIR/$folder"
}

monitor_and_sync() {
    local folder=$1
    if [ -d "$LOCAL_DIR/$folder" ]; then
        echo "Monitoring $LOCAL_DIR/$folder for changes..." | tee -a "$LOG_FILE"
        inotifywait -mr -e modify,create,delete,move --format '%w%f' "$LOCAL_DIR/$folder" | while read change; do
            echo "Change detected in $folder: $change. Synchronizing..." | tee -a "$LOG_FILE"
            if ! rclone sync "$LOCAL_DIR/$folder" "$REMOTE:$folder" --update --verbose --log-file="$LOG_FILE"; then
                echo "Error: local-to-remote synchronization failed for $folder. Check logs: $LOG_FILE" | tee -a "$LOG_FILE"
            fi
            if ! rclone sync "$REMOTE:$folder" "$LOCAL_DIR/$folder" --update --verbose --log-file="$LOG_FILE"; then
                echo "Error: remote-to-local synchronization failed for $folder. Check logs: $LOG_FILE" | tee -a "$LOG_FILE"
            fi
            adjust_permissions "$folder"
        done
    else
        echo "Directory $LOCAL_DIR/$folder not found. Cannot start monitoring." | tee -a "$LOG_FILE"
    fi
}

ensure_dependencies
setup_log_file
initial_sync

for FOLDER in "${FOLDERS[@]}"; do
    monitor_and_sync "$FOLDER" &
    sleep 1
done

wait
