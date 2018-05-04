#!/bin/bash

#  NOTE: Run this cron job as root as it requires sudo privileges. Use the following command-
#     sudo -u <your-username> crontab -e
#  And put the following line in it.
#     @reboot $USER_HOME/cronJobs/changeGrubBG.sh
# ^ For different settings, checkout https://crontab.guru/
# Also make sure that there are no image files in /boot/grub (else that image will get selected)

#Configure this-
USER_NAME=udayraj
USER_HOME=/home/$USER_NAME

# This line is expected to exist already in /etc/default/grub
# GRUB_BACKGROUND="some/random/path"
CURR_FILE=$(cat /etc/default/grub | grep BACKGROUND) # Get grub current line
CURR_FILE=$(cut -d "=" -f 2 <<< "$CURR_FILE")        # File name only
CURR_FILE=$(echo "$CURR_FILE" | tr -d '"')           # Remove double quotes
IMG_DIR=$USER_HOME/Pictures/grubs;
echo "Image directory '$IMG_DIR'";
ls $IMG_DIR;
echo $(date +%d/%m' '%T) ": Found current bg as : '$CURR_FILE'";
for ALL_FILES in $IMG_DIR/*; do # Loop through every file
    if [[ "$FIRST_FILE" == "" ]]; then
        FIRST_FILE="$ALL_FILES"
    elif [[ "$MATCH_FILE" != "" ]]; then
        NEXT_FILE="$ALL_FILES"
        break # We've got it!
    fi
    if [[ "$CURR_FILE" == "$ALL_FILES" ]]; then
        MATCH_FILE="$ALL_FILES" # We found our current file entry
    fi
done

# If $NEXT_FILE empty we hit end of list so use First file name
if [[ "$NEXT_FILE" == "" ]]; then
    NEXT_FILE="$FIRST_FILE"
fi

NEXT_FILE_NAME=$(basename "$NEXT_FILE");
msg="$(date +%d/%m' '%T) : Changed bg image to '$NEXT_FILE_NAME'";
echo $msg;

# replace background file name in grub source file
sed -i "s|$CURR_FILE|$NEXT_FILE|g" /etc/default/grub

# Send a notification
DISPLAY=:0.0 #needed when inside cron 
su $USER_NAME -c "notify-send \"Grub BG Changer\" \"Changed bg image to '$NEXT_FILE_NAME'\""
# ^Single quotes won't decode the variables beforehand
echo $msg >> $USER_HOME/cronJobs/cronLog

# replace background file name in grub configuration file
# ^Short cut so we don't have to run `sudo update-grub`
# Backup... just in case :)
# cp /boot/grub/grub.cfg /boot/grub/grub.cfg~
# sed -i "s|$CURR_FILE|$NEXT_FILE|g" /boot/grub/grub.cfg

update-grub >> $USER_HOME/cronJobs/cronLog
