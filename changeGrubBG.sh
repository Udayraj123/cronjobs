#!/bin/bash
# e.g. GRUB_BACKGROUND="/home/udayraj021/Pictures/grubs/1.jpg"
CURR_FILE=$(cat /etc/default/grub | grep BACKGROUND) # Get grub current line

CURR_FILE=$(cut -d "=" -f 2 <<< "$CURR_FILE")        # File name only
CURR_FILE=$(echo "$CURR_FILE" | tr -d '"')           # Remove double quotes
for ALL_FILES in /home/udayraj021/Pictures/grubs/*; do # Loop through every file
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


# replace background file name in grub source file
sed -i "s|$CURR_FILE|$NEXT_FILE|g" /etc/default/grub

notify-send "Grub BG Changer" ": Changed bg image to $NEXT_FILE"
echo $(date +%d/%m' '%T) ": Changed bg image to $NEXT_FILE" >> /home/udayraj021/cronJobs/cronLog

# replace background file name in grub configuration file
# Backup... just in case :)
# cp /boot/grub/grub.cfg /boot/grub/grub.cfg~
# Short cut so we don't have to run `sudo update-grub`
# sed -i "s|$CURR_FILE|$NEXT_FILE|g" /boot/grub/grub.cfg

update-grub >> /home/udayraj021/cronJobs/cronLog
