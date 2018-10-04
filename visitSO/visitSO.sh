# utility logger
cronLog(){
	msg="[$(date +%d/%m' '%T)] $1";
	echo $msg;
	touch ./cronLog;
	echo $msg >> ./cronLog;
}
if [ ! -d ignore ]; then 
	echo "Creating ignore directory..";
	mkdir ignore;
fi
login_file='./ignore/so.encpwd'
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

# Plain method:
# EMAIL='stackoverflowyouremailhere';
# PASSWD='yourpasswordhere';
LOGIN_DATA="email=$EMAIL&password=$PASSWD";	

# (pseudo) Encrypted method:
echo "Loading details from encrypted file";
LOGIN_DATA=$(cat $login_file | openssl enc -d -aes-128-cbc -a -salt -pass pass:mysalt)
cronLog "Logging in...";
curl -d "$LOGIN_DATA" --dump-header ./ignore/headers https://stackoverflow.com/users/login
echo
cronLog "Done. Visiting Home page..";
curl -o ignore/del.html -L -b ./ignore/headers https://stackoverflow.com/
echo
cronLog "Done.";
cat ignore/del.html | grep --color my-profile

LOGIN_DATA='clearedpass';
