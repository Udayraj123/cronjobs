#!/bin/bash

# if [ $EUID -ne 0 ]; then
#     echo "Please run as root";
#     exit 1;
# fi
# _black=$(tput setaf 0);	_red=$(tput setaf 1);
_green=$(tput setaf 2);	_yellow=$(tput setaf 3);
# _blue=$(tput setaf 4);	_magenta=$(tput setaf 5);
# _cyan=$(tput setaf 6);	_white=$(tput setaf 7);
_reset=$(tput sgr0);		_bold=$(tput bold);

echo "$_bold$_yellow Welcome to SO Login Script! $_reset"
echo "$_yellow Complete two badges (Enthusiast & Fanatic) by adding a cron job! $_reset";

FILE_NAME="visitSO.sh"
# read -p "Confirm the file name: \n" -i "$FILE_NAME" -e FILE_NAME

# when run from full path
FILE_DIR="${BASH_SOURCE%/*}";
# when run locally
if [ ! -d $FILE_DIR ] || [ "$FILE_DIR" == "." ]; then FILE_DIR="$PWD"; fi

FULL_PATH="$FILE_DIR/$FILE_NAME"

if [ ! -e $FULL_PATH ]; then
	echo "$_yellow Warning: visitSO.sh File not found at '$FULL_PATH' $_reset";
	echo "$_yellow The cron job may not have any effect, Do you want to continue? (any/n) $_reset"
	read CONTINUE;
	if [ $CONTINUE == "n" ];then
		echo "Exiting";
		exit 0;
	fi
	# echo "Error: File not found: '$FULL_PATH'";
	# exit 1;
fi

if [ ! -d $FILE_DIR/ignore ]; then 
	echo "Creating ignore directory..";
	mkdir $FILE_DIR/ignore;
fi

login_file="$FILE_DIR/ignore/so.encpwd"
if [ ! -f $login_file ]; then 
	echo "Password file not found(First run?). Creating one now: ";
	#Set password into encrypted file
	echo -n "Enter SO email: ";
	read EMAIL
	echo -n "Enter password for '$EMAIL' : ";
	read -rs PASSWD
	LOGIN_DATA="email=$EMAIL&password=$PASSWD";	
	echo "Saving details in encrypted file";
	touch $login_file;
	echo "$LOGIN_DATA" | openssl enc -aes-128-cbc -a -salt -pass pass:mysalt > $login_file;	
fi


# msg goes into stderr
crontab -l > ./tmp_cron 2> /dev/null

echo "Confirm the cron line: (Default repeat = 6 hours, you can change the */6 part)";
CRON_LINE="0 */6 * * * cd $FILE_DIR && bash $FULL_PATH ;";
read -i "$CRON_LINE" -e CRON_LINE


cat ./tmp_cron | grep --color "$FILE_DIR"
FOUND=$?;
if [ "$FOUND" == "0" ]; then
	echo
	echo "Seems like a similar job is already present. $_yellow You can clear the cron table by running 'crontab -r' $_reset";
	echo "Do you still want to add this line? (any/n)"
	read CONTINUE;
	if [ $CONTINUE == "n" ];then
		echo "Exiting";
		rm ./tmp_cron;
		exit 0;
	fi
fi
echo "$_green Adding cron job.. $reset"
#echo new cron into cron file
echo "$CRON_LINE" >> ./tmp_cron;
#install new cron file
crontab ./tmp_cron;
echo "$_green Done. Cron will now run $FILE_DIR/$FILE_NAME periodically $reset";
rm ./tmp_cron;
