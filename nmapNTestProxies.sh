#!/bin/bash

#  NOTE: To add this cronjob, Use the following command-
#   crontab -e
#  And put the following line in it.
# 	0 */2 * * * $HOME/cronJobs/nmapNTestProxies.sh
#  ^ Runs every 2 hours, for different settings, checkout https://crontab.guru/

#TODO: currently the list has to be hardcoded down below
# IPList="" #$( some nmap command )

# associative array:
declare -A portToIPList
portToIPList["808"]="172.16.41.23 172.16.83.164 172.16.83.197 172.16.83.199"
portToIPList["8080"]="172.16.41.23 172.16.83.81 172.16.83.123 172.16.83.154"
portToIPList["3128"]="172.16.101.138 172.16.114.238 172.16.114.239 172.16.41.23 172.16.83.193 172.16.83.201 172.16.83.205"
#TODO: Load above from nmap^ nmap -v -ns 172.16.0.0/16

old_http_proxy=$http_proxy
old_https_proxy=$https_proxy
output=""
append=$(printf "%s :%s\t  %s \n" " IP address " "port" "Status")
printf "$append\n";
output="$output$append\n" 
for port in ${!portToIPList[@]}; do
	IPList=${portToIPList[$port]}
	
	for IP in $IPList; do
		export https_proxy="http://$IP:$port";
		export http_proxy="http://$IP:$port";
		Error=$(wget -t 1 -O /dev/null  google.com 2>&1 | grep "Proxy" | awk  'BEGIN{FS="\.\.\.";ORS=" ";}{print $2;}');
		append=$(printf "%s:%s\t %s \n" "$IP" "$port" "$Error")
		printf "$append\n";
		output="$output$append\n" 
	done;
	printf "\n"
	output="$output\n" 
done;

# echo -e "$output"; # -e for  printing \n
# printf "$output"; # alternative.
OKoutput=$(echo -e "$output"| grep "OK")
DISPLAY=:0.0 #needed when inside cron 
notify-send "Proxies Scan Report" "$OKoutput";
echo -e $(date +%d/%m' '%T) "Proxies Scan Report:\n" "$OKoutput" >> $HOME/cronJobs/cronLog

export http_proxy=$old_http_proxy
export https_proxy=$old_https_proxy
