# colors!
_black=$(tput setaf 0);	_red=$(tput setaf 1);
_green=$(tput setaf 2);	_yellow=$(tput setaf 3);
_blue=$(tput setaf 4);	_magenta=$(tput setaf 5);
_cyan=$(tput setaf 6);	_white=$(tput setaf 7);
_reset=$(tput sgr0);		_bold=$(tput bold);

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
cronLog "Done.";
output=$(cat $FILE_DIR/ignore/stackoverflow.html | grep --color my-profile);
cronLog "$output";

rm $FILE_DIR/ignore/headers;
LOGIN_DATA='clearedpass';

