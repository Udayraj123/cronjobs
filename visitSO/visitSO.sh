# when run from full path
FULL_PATH="${BASH_SOURCE%/*}";
# when run locally
if [ ! -d $FULL_PATH ] || [ "$FULL_PATH" == "." ]; then FULL_PATH="$PWD"; fi
# Make directories if they don't exist
if [ ! -d $FULL_PATH/ignore ]; then 
	echo " Creating ignore directory..";
	mkdir $FULL_PATH/ignore;
fi

source $FULL_PATH/utils.sh;

cronLog "Logging in...";
curl \
-H 'authority: stackoverflow.com' \
-H 'upgrade-insecure-requests: 1' \
-H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.77 Safari/537.36' \
-H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' \
-H 'referer: https://stackoverflow.com/' \
-H 'accept-encoding: gzip, deflate, br' \
-H 'accept-language: en-GB,en-US;q=0.9,en;q=0.8' \
-d "$LOGIN_DATA" --dump-header $FULL_PATH/ignore/headers \
https://stackoverflow.com/users/login;

for i in {1..2}
do
	cronLog "Visiting with same login after 10s intervals";
	echo
	curl -o "$FULL_PATH/ignore/stackoverflow.html" -L -b $FULL_PATH/ignore/headers https://stackoverflow.com/
	echo
	cronLog "Done. Searching for 'my-profile'";
	output=$(cat $FULL_PATH/ignore/stackoverflow.html | grep --color -i my-profile);
	cronLog "$output";
	sleep 10;
done;
# cleanup
rm $FULL_PATH/ignore/headers;
LOGIN_DATA='clearedpass';

