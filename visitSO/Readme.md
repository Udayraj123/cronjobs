# Stackoverflow login script!
## How to use
1. Make sure you can login using **email** and password on *http://stackoverflow.com*. 

If you logged in using facebook, goto your profile -> Edit Profile & Settings -> My logins(under 'SITE SETTINGS') -> 'add more logins'
 and add an email to login with.

2. Run setup.sh

```bash setup.sh```

Enter the details and hit enter and Whola! The now you can sit back and relax, Cron will login for you!

:warning: **Enter credentials at your own risk! This script is best kept only for personal use.** :warning:

3. Make sure it works!

Just to make sure the script can login, you can run it now: 

```bash visitSO.sh```

The output should contain a matching line to your profile id as shown below:

```<a href="/users/6242649/udayraj-deshmukh" class=...```

In case you had entered wrong credentials, simply delete the ignore/so.encpwd file and run visitSO.sh again!

Note: instead of `bash XYZ.sh` you can also chmod the scripts first and then run `./XYZ.sh`

## Details  & Explanations
When running setup.sh for the first time, it will ask you for your email and password which will get stored in an (pseudo)encrypted file, which would look like this: 

>  U2FsdGVkX1/7/tGjsomemorerandomhashedcharsY8HCLVaC
>
>  bS6hBzA/0Zx8DoElsomemorerandomhashedcharsO6c0lwsa

(Its pseudo-encryption as the key to decrypt the file is also used by the same script.)
Then it will add a cron job in your linux system which looks like this: 

> ` 0 */6 * * * bash /path/to/cronJobs/visitSO/visitSO.sh ;`

Which says:  
> at 0th minute of every 6th hour of every day, run the script visitSO.sh
>
> The program also asks you to confirm if 6 hour is fine, so you can change it as you wish.

Note: `visitSO.sh` will log its visits in the cronLog file. You can see it work there.
