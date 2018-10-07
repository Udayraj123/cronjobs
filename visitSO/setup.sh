#!/bin/bash

# if [ $EUID -ne 0 ]; then
#     echo "Please run as root";
#     exit 1;
# fi

echo "Welcome to SO Login Script! Complete two badges (Enthusiast & Fanatic) by adding a cron job!";

# when run from full path
FILE_DIR="${BASH_SOURCE%/*}";
# when run locally
if [ ! -d $FILE_DIR ]; then FILE_DIR="$PWD"; fi

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


crontab -l > ./tmp_cron
# msg goes into stderr
FILE_NAME="visitSO.sh"
# read -p "Confirm the file name: \n" -i "$FILE_NAME" -e FILE_NAME

FULL_PATH="$FILE_DIR/$FILE_NAME"

if [ ! -e $FULL_PATH ]; then
	echo "Warning: File not found: '$FULL_PATH'";
	echo "The cron job may not have any effect";
	# echo "Error: File not found: '$FULL_PATH'";
	# exit 1;
fi
CRON_LINE="0 */6 * * * cd $FILE_DIR && bash $FULL_PATH ;";
read -p "Confirm the cron line: \n" -i "$CRON_LINE" -e CRON_LINE

cat ./tmp_cron | grep --color "$FILE_DIR"

FOUND=$?;
if [ "$FOUND" == "0" ]; then
	echo
	echo "Seems like a similar job is already present. Do you still want to add this line? (any/n)";
	read CONTINUE;
	if [ $CONTINUE == "n" ];then
		echo "Exiting";
		rm ./tmp_cron;
		exit 0;
	fi
fi
echo "Adding cron job.."
#echo new cron into cron file
echo "$CRON_LINE" >> ./tmp_cron;
#install new cron file
crontab ./tmp_cron;
echo "Done. Cron will now run $FILE_DIR/$FILE_NAME periodically";
rm ./tmp_cron;
