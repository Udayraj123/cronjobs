login_file="$FULL_PATH/ignore/so.encpwd"
# utility logger
cronLog(){
	msg="[$(date +%d/%m' '%T)] $1";
	echo $msg;
	touch $FULL_PATH/cronLog;
	echo $msg >> $FULL_PATH/cronLog;
}
# Init
LOGIN_DATA='';

# Plain method:
# EMAIL='stackoverflowyouremailhere';
# PASSWD='yourpasswordhere';
# LOGIN_DATA="email=$EMAIL&password=$PASSWD";	

# If Plain Method not used - load from file 
if [ "$LOGIN_DATA" == "" ]; then 
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
fi
