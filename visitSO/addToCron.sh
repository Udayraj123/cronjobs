#!/bin/bash
#  Running as one time : to set/change grub bg
# if [ $EUID -ne 0 ]; then
#     echo "Please run as root";
#     exit 1;
# fi
# write out current crontab
crontab -l > ./tmp_cron
# msg goes into stderr
FILE_NAME="visitSO.sh"
FILE_PATH="$(pwd)/$FILE_NAME";
CRON_LINE="0 */6 * * * $FILE_PATH";
read -p "Confirm the cron line: " -i $CRON_LINE -e CRON_LINE

cat ./tmp_cron | grep --color "$FILE_PATH"

FOUND=$?;
if [ "$FOUND" == "0" ]; then
	echo "Seems like the job is already present. Do you still want to add this line? (any/n)";
	read CONTINUE;
	if [ $CONTINUE == "n" ];then
		echo "Exiting";
		rm ./tmp_cron;
		exit 0;
	fi
fi
echo "Adding cron line: "
#echo new cron into cron file
echo "$CRON_LINE" >> ./tmp_cron;
#install new cron file
crontab ./tmp_cron;
echo "Done";
rm ./tmp_cron;