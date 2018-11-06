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

LOOP_URL="https://stackoverflow.com";
VISIT_URL="$LOOP_URL";
PROFILE_LINK=''
for i in {1..2}
do
	[[ "$i" != "1" ]] && cronLog "Waiting 10s before next visit" && sleep 10;
	echo
	if [ "$PROFILE_LINK" == "" ]; then
		cronLog "Visiting Home page..";
		echo
		curl  -o "$FULL_PATH/ignore/visited.html" -L -b $FULL_PATH/ignore/headers "$VISIT_URL"
		echo
		cronLog "Done. Searching for 'my-profile'";
		output=$(cat "$FULL_PATH/ignore/visited.html" | grep --color -i my-profile);
		cronLog "$output";

		PROFILE_LINK=$(echo $output | awk -F'\"' '{print $2}');
		PROFILE_LINK="${LOOP_URL}${PROFILE_LINK}"
		cronLog "Extracted Profile Link:  $PROFILE_LINK "
	else
		cronLog "Visiting Profile page..";
		curl  -o "$FULL_PATH/ignore/visited.html" -L -b $FULL_PATH/ignore/headers "$PROFILE_LINK"
		output=$(cat "$FULL_PATH/ignore/visited.html");
		cronLog "$output";
		PROFILE_LINK=''
	fi
done;
# cleanup
rm $FULL_PATH/ignore/headers;
LOGIN_DATA='clearedpass';

