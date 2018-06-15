#!/bin/bash
#  Running as one time : to set/change grub bg
if [ $EUID -ne 0 ]; then
    echo "Please run as root";
    exit 1;
fi
# Running in cron mode
#  NOTE: Run this cron job as root as it requires sudo privileges. Use the following command-
#     sudo -u <your-username> crontab -e
#  And put the following line in it.
#     @reboot $USER_HOME/cronJobs/changeGrubBG.sh
# ^ For different settings, checkout https://crontab.guru/
# Also make sure that there are no image files in /boot/grub (else that image will get selected)

# https://unix.stackexchange.com/questions/11470/how-to-get-the-name-of-the-user-that-launched-sudo?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
USER_NAME=$SUDO_USER
USER_HOME=/home/$USER_NAME
# TODO- resolve - This line is expected to exist already in /etc/default/grub

IMG_DIR=$USER_HOME/Pictures/grubs;
# Check directory exists
if [ ! -d $IMG_DIR ]; then
    echo "Directory '$IMG_DIR' doesn't exist. Creating now:"
    mkdir $IMG_DIR;
    echo "Put your backgrounds for grub there!"
    exit 1;
fi

# line is:  GRUB_BACKGROUND="/path/to/your/bg.jpg"
CURR_FILE=$(cat /etc/default/grub | grep BACKGROUND) # Get grub current line
# Check BG line exists
if [[ "$CURR_FILE" == "" ]]; then
    echo "No previous bg set. Adding a dummy image:";
    cp ./dummy.jpg $IMG_DIR/dummy.jpg
    chmod 777 $IMG_DIR/dummy.jpg;
    echo "GRUB_BACKGROUND=$IMG_DIR/dummy.jpg" | sudo tee -a /etc/default/grub
fi
CURR_FILE=$(cat /etc/default/grub | grep BACKGROUND) # Get grub current line
CURR_FILE=$(cut -d "=" -f 2 <<< "$CURR_FILE")        # File path only
CURR_FILE=$(echo "$CURR_FILE" | tr -d '"')           # Remove double quotes

echo 
echo "Searching in Image directory $_green '$IMG_DIR' $_reset";
ls $IMG_DIR;
echo 
echo $(date +%d/%m' '%T) ": Found current bg as : $_green '$CURR_FILE' $_reset";

shopt -s nullglob # set nullglob; If no files exist, make the string null!
JPG_IMAGES="$IMG_DIR/*.jpg"
PNG_IMAGES="$IMG_DIR/*.png"
ALL_IMAGES="$JPG_IMAGES $PNG_IMAGES";
# TODO - Remove this dependency-
shopt -u nullglob # make it back to unset!

if [[ "$ALL_IMAGES" == " " ]]; then
    echo "No images found in $IMG_DIR!";
    exit 1;
fi
for LOOP_FILE in $ALL_IMAGES; do # Loop through every file
if [[ "$FIRST_FILE" == "" ]]; then
    FIRST_FILE="$LOOP_FILE"
elif [[ "$MATCH_FILE" != "" ]]; then
    NEXT_FILE="$LOOP_FILE"
     # We've got it!
     break
 fi
 if [[ "$CURR_FILE" == "$LOOP_FILE" ]]; then
    # We found our current bg 
    MATCH_FILE="$LOOP_FILE" 
fi
done

# If $NEXT_FILE empty we hit end of list so use First file name
if [[ "$NEXT_FILE" == "" ]]; then
    NEXT_FILE="$FIRST_FILE"
fi

NEXT_FILE_NAME=$(basename "$NEXT_FILE");
msg="$(date +%d/%m' '%T) : Changed bg image to '$NEXT_FILE_NAME'";
echo $msg;

# replace background file path in grub source file
sed -i "s|$CURR_FILE|$NEXT_FILE|g" /etc/default/grub

# Send a notification
DISPLAY=:0.0 #needed when inside cron 
su $USER_NAME -c "notify-send \"Grub BG Changer\" \"Changed bg image to '$NEXT_FILE_NAME'\""
# ^Single quotes won't decode the variables beforehand
echo $msg >> ./cronLog

# replace background file name in grub configuration file
# ^Short cut so we don't have to run `sudo update-grub`
# Backup... just in case :)
# cp /boot/grub/grub.cfg /boot/grub/grub.cfg~
# sed -i "s|$CURR_FILE|$NEXT_FILE|g" /boot/grub/grub.cfg

update-grub >> ./cronLog
