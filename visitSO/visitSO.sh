
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

# Lets curl!
cronLog "Logging in...";
curl -d "$LOGIN_DATA" --dump-header $FILE_DIR/ignore/headers https://stackoverflow.com/users/login
echo
cronLog "Done. Visiting Home page..";
curl -o $FILE_DIR/ignore/stackoverflow.html -L -b $FILE_DIR/ignore/headers https://stackoverflow.com/
echo
cronLog "Done. Searching for 'my-profile'";
output=$(cat $FILE_DIR/ignore/stackoverflow.html | grep --color -i my-profile);
cronLog "$output";

rm $FILE_DIR/ignore/headers;
LOGIN_DATA='clearedpass';

