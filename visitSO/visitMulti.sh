# when run from full path
FULL_PATH="${BASH_SOURCE%/*}";
# when run locally
if [ ! -d $FULL_PATH ] || [ "$FULL_PATH" == "." ]; then FULL_PATH="$PWD"; fi
# Make directories if they don't exist
if [ ! -d $FULL_PATH/ignore ]; then 
	echo " Creating ignore directory..";
	mkdir $FULL_PATH/ignore;
fi

source $FULL_PATH/utils.sh

for URL_FILE in "domains.list"; do
	# Loop through every url
	ALL_URLS=$(cat $FULL_PATH/$URL_FILE);
	for LOOP_URL in $ALL_URLS; do 
		# if [[ "$LOGIN_URL" == "" ]]; then
		# else
		# fi 
		# This script can work on any url that uses 'email' & 'password' as form parameters
		LOGIN_URL="$LOOP_URL/users/login";
		VISIT_URL="$LOOP_URL";
		VISIT_DOMAIN=$(echo "$LOOP_URL" | cut -d'/' -f3 | cut -d':' -f1);
		# echo "Domain: $VISIT_DOMAIN";
		cronLog "Logging in at '$LOGIN_URL'...";
		curl \
		-H "authority: $VISIT_DOMAIN" \
		-H "upgrade-insecure-requests: 1" \
		-H "user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.77 Safari/537.36" \
		-H "accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8" \
		-H "referer: $VISIT_URL/" \
		-H "accept-encoding: gzip, deflate, br" \
		-H "accept-language: en-GB,en-US;q=0.9,en;q=0.8" \
		-d "$LOGIN_DATA" --dump-header $FULL_PATH/ignore/headers \
		"$LOGIN_URL";

		cronLog "Done. Visiting '$VISIT_URL'..";
		# Lets curl!
		for i in {1..2}
		do
			[[ "$i" != "0" ]] && cronLog "Visiting with same login at 10s intervals" && sleep 10;
			echo
			curl  -o "$FULL_PATH/ignore/visited.html" -L -b $FULL_PATH/ignore/headers "$VISIT_URL"
			echo
			cronLog "Done. Searching for 'my-profile'";
			output=$(cat "$FULL_PATH/ignore/visited.html" | grep --color -i my-profile);
			cronLog "$output";
		done;
	done
done
rm $FULL_PATH/ignore/headers;
LOGIN_DATA='clearedpass';

# Read urls line by line
# while IFS='' read -r LOOP_URL || [[ -n "$LOOP_URL" ]]; do
# done < "$FULL_PATH/urls.list"

# -b = cookies data/ binary file
# -L = follow redirects
