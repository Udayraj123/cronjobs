# utility logger
cronLog(){
    msg="[$(date +%d/%m' '%T)] $1";
    echo $msg;
    touch ./cronLog;
    echo $msg >> ./cronLog;
}
# Run this command when running first time:
# PASSWD='stackoverflowpasswordhere';
# echo $PASSWD | openssl enc -aes-128-cbc -a -salt -pass pass:mysalt > /root/.sopwd;	

EMAIL='stackoverflowyouremailhere';
PASSWD=$(cat /root/.sopwd | openssl enc -d -aes-128-cbc -a -salt -pass pass:mysalt);

cronLog "Logging in...";
curl -o del.html -d "email=$EMAIL&password=$PASSWD" --dump-header headers https://stackoverflow.com/users/login
echo $?;
cronLog "Done. Visiting some page..";
curl -o del.html -L -b headers https://stackoverflow.com/users/edit/6242649
echo $?;
cronLog "Done.";
PASSWD='clearedpass';
