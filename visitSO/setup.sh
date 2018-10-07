#!/bin/bash

# if [ $EUID -ne 0 ]; then
#     echo "Please run as root";
#     exit 1;
# fi

# colors!
_black=$(tput setaf 0);	_red=$(tput setaf 1);
_green=$(tput setaf 2);	_yellow=$(tput setaf 3);
_blue=$(tput setaf 4);	_magenta=$(tput setaf 5);
_cyan=$(tput setaf 6);	_white=$(tput setaf 7);
_reset=$(tput sgr0);		_bold=$(tput bold);

echo "$_cyan WELCOME TO SO LOGIN SCRIPT! $_reset"
echo "$_cyan Complete the Enthusiast & Fanatic badges by adding a simple cron job! $_reset";
echo
FILE_NAME="visitSO.sh"
# read -p "Confirm the file name: \n" -i "$FILE_NAME" -e FILE_NAME

# when run from full path
FILE_DIR="${BASH_SOURCE%/*}";
# when run locally
if [ ! -d $FILE_DIR ] || [ "$FILE_DIR" == "." ]; then FILE_DIR="$PWD"; fi

FULL_PATH="$FILE_DIR/$FILE_NAME"

if [ ! -e $FULL_PATH ]; then
	echo "$_yellow Warning: visitSO.sh File not found at '$FULL_PATH' $_reset";
	echo "$_red The cron job may not have any effect, Do you want to continue? (any/n) $_reset"
	read CONTINUE;
	if [ "$CONTINUE" == "n" ];then
		echo "Exiting";
		exit 0;
	fi
	# echo "Error: File not found: '$FULL_PATH'";
	# exit 1;
fi

if [ ! -d $FILE_DIR/ignore ]; then 
	echo "$_yellow Creating ignore directory..";
	mkdir $FILE_DIR/ignore;
fi

login_file="$FILE_DIR/ignore/so.encpwd"
if [ ! -f $login_file ]; then 
	echo "$_yellow Password file not found(First run?). Creating one now: ";
	#Set password into encrypted file
	echo -n "$_blue Enter SO email: ";
	read EMAIL
	echo -n "$_blue Enter password for '$EMAIL' : ";
	read -rs PASSWD
	LOGIN_DATA="email=$EMAIL&password=$PASSWD";	
	echo "$_blue Saving details in (pseudo)encrypted file";
	touch $login_file;
	echo "$LOGIN_DATA" | openssl enc -aes-128-cbc -a -salt -pass pass:mysalt > $login_file;	
fi


# msg goes into stderr
crontab -l > ./tmp_cron 2> /dev/null

# echo "$_blue Confirm the cron line to add:"; #  $_yellow (You can change interval in hours by changing the '*/6' part) $_reset
# CRON_LINE="0 */6 * * * cd $FILE_DIR && bash $FULL_PATH ;";
CRON_LINE="0 */6 * * * bash $FULL_PATH ;";
echo "$_blue Confirm the cron line to add: $_reset"
# colors dont go well with read command
read -i "$CRON_LINE" -e CRON_LINE

# assigning command returns the return signal of RHS
# output=$(cat ./tmp_cron | grep --color "$FILE_DIR")
# but newline characters get lost!

echo "$_blue Checking if the job exists already.. $_reset";
cat ./tmp_cron | grep --color "$FILE_DIR";
FOUND=$?;
if [ "$FOUND" == "0" ]; then
	echo "$_yellow Similar job(s) already present in cron table: $_reset";
	# echo "$_yellow Note: You can clear the cron table later by running 'crontab -r' $_reset"
	read -p "$_yellow Do you still want to add this line? (any/n) $_reset" CONTINUE;
	if [ "$CONTINUE" == "n" ];then
		echo "$_green Exiting $_reset";
		rm ./tmp_cron;
		exit 0;
	fi
else;
	echo "$_blue No matching entry exists.";
fi
echo "$_blue Adding cron job.. $_reset"
#echo new cron into cron file
echo "$CRON_LINE" >> ./tmp_cron;
#install new cron file
crontab ./tmp_cron;
rm ./tmp_cron;
echo "$_green Done adding. $_reset";
echo "$_blue  Listing crontable: $_reset";
crontab -l;