#!/bin/bash
# IPList="" #$( some nmap command )

# associative array:
declare -A portToIPList
portToIPList["808"]="172.16.83.164 172.16.83.197 172.16.83.199"
portToIPList["8080"]="172.16.83.81 172.16.83.123 172.16.83.154"
portToIPList["3128"]="172.16.83.193 172.16.83.201 172.16.83.205"
old_http_proxy=$http_proxy
old_https_proxy=$https_proxy

for port in ${!portToIPList[@]}; do
	IPList=${portToIPList[$port]}
	printf "Testing proxies with port '%s' \n" "$port"
	for IP in $IPList; do
		export https_proxy="http://$IP:$port";
		export http_proxy="http://$IP:$port";
		Error=$(wget -t 1 -O /dev/null  google.com 2>&1 | grep "Proxy" | awk  'BEGIN{FS="\.\.\.";ORS=" ";}{print $2;}');
		printf "%s:%s -> %s \n" "$IP" "$port" "$Error"
	
	done;
	printf "\n"
done;

export http_proxy=$old_http_proxy
export https_proxy=$old_https_proxy
