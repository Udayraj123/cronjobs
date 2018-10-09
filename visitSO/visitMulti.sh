
# when run from full path
FILE_DIR="${BASH_SOURCE%/*}";
# when run locally
if [ ! -d $FILE_DIR ] || [ "$FILE_DIR" == "." ]; then FILE_DIR="$PWD"; fi

# utility logger
cronLog(){
	msg="[$(date +%d/%m' '%T)] $1";
	echo $msg;
	touch $FILE_DIR/cronLog;
	echo $msg >> $FILE_DIR/cronLog;
}
# Plain method:
# EMAIL='stackoverflowyouremailhere';
# PASSWD='yourpasswordhere';
# LOGIN_DATA="email=$EMAIL&password=$PASSWD";	

if [ ! -d $FILE_DIR/ignore ]; then 
	echo " Creating ignore directory..";
	mkdir $FILE_DIR/ignore;
fi

login_file="$FILE_DIR/ignore/so.encpwd"
if [ ! -f $login_file ]; then 
	echo " Password file not found(First run?). Creating one now: ";
	#Set password into encrypted file
	echo -n " Enter SO email: ";
	read EMAIL
	echo -n " Enter password for '$EMAIL' : ";
	read -rs PASSWD
	LOGIN_DATA="email=$EMAIL&password=$PASSWD";	
	echo " Saving details in (pseudo)encrypted file";
	touch $login_file;
	echo "$LOGIN_DATA" | openssl enc -aes-128-cbc -a -salt -pass pass:mysalt > $login_file;	
fi
# (pseudo) Encrypted method:
echo "Loading details from encrypted file";
LOGIN_DATA=$(cat $login_file | openssl enc -d -aes-128-cbc -a -salt -pass pass:mysalt)

# Loop through every url
ALL_URLS=$(cat $FILE_DIR/urls.list);
for LOOP_URL in $ALL_URLS; do 
	if [[ "$LOGIN_URL" == "" ]]; then
		# first url is the login url, rest are visit urls.
		# Make sure login url is one of the stackexchange sites and not stackoverflow, etc!
		# tho This script can work on any url that uses 'email' & 'password' as form parameters
	    LOGIN_URL="$LOOP_URL"
		cronLog "Logging in at '$LOGIN_URL'...";
		# curl -d "$LOGIN_DATA" --dump-header $FILE_DIR/ignore/headers "$LOGIN_URL"
	else
	# Lets curl!
	    VISIT_URL="$LOOP_URL"
		echo
		cronLog "Done. Visiting '$VISIT_URL'..";
		# curl -o "$FILE_DIR/ignore/visited.html" -L -b $FILE_DIR/ignore/headers "$VISIT_URL"
		echo
		cronLog "Done.";
		output=$(cat "$FILE_DIR/ignore/visited.html" | grep --color my-profile);
		cronLog "$output";
		rm $FILE_DIR/ignore/headers;
		# rm $FILE_DIR/ignore/visited.html;    
	fi 
done
LOGIN_DATA='clearedpass';

# Read urls line by line
# while IFS='' read -r LOOP_URL || [[ -n "$LOOP_URL" ]]; do
# done < "$FILE_DIR/urls.list"
