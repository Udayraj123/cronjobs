#!/bin/bash
# IPList="" #$( some nmap command )

# associative array:
declare -A portToIPList
portToIPList["808"]="172.16.83.164 172.16.83.197 172.16.83.199"
portToIPList["8080"]="172.16.83.81 172.16.83.123 172.16.83.154"
portToIPList["3128"]="172.16.83.193 172.16.83.201 172.16.83.205"
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
notify-send "Proxies Scan Report" "$OKoutput";
export http_proxy=$old_http_proxy
export https_proxy=$old_https_proxy
