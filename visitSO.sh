EMAIL='stackoverflowyouremailhere';
PASSWD='stackoverflowpasswordhere';

# Run this command when running first time:
# echo $PASSWD | openssl enc -aes-128-cbc -a -salt -pass pass:mysalt > /root/.sopwd;	

PASSWD=$(cat /root/.sopwd | openssl enc -d -aes-128-cbc -a -salt -pass pass:mysalt);
curl -o del.html -d "email=$EMAIL&password=$PASSWD" --dump-header headers https://stackoverflow.com/users/login
curl -o del.html -L -b headers https://stackoverflow.com/users/edit/6242649
