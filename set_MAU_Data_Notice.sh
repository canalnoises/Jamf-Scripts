#!/bin/sh

# Sets the AcknowledgedDataCollectionPolicy key in Microsoft AutoUpdate's 
# preferences to RequiredDataOnly so the current user won't be presented with 
# the Required Data Notice on their first launch of MAU.

# https://docs.microsoft.com/en-us/deployoffice/privacy/mac-privacy-preferences#preference-setting-for-the-required-data-notice-dialog-for-microsoft-autoupdate

# Written by Isaac Nelson <isaac.nelson@churchofjesuschrist.org> 26 Sep 2019

loggedInUser=$( /bin/echo "show State:/Users/ConsoleUser" | /usr/sbin/scutil | /usr/bin/awk '/Name :/ && ! /loginwindow/ { print $3 }' )

/bin/echo "Setting MAU AcknowledgedDataCollectionPolicy to RequiredDataOnly for ${loggedInUser} so they won't be presented with the Required Data Notice on the first launch of MAU."

/usr/bin/su "${loggedInUser}" -c "/usr/bin/defaults write com.microsoft.autoupdate2 AcknowledgedDataCollectionPolicy RequiredDataOnly"

result=$(/usr/bin/su "${loggedInUser}" -c "/usr/bin/defaults read com.microsoft.autoupdate2 AcknowledgedDataCollectionPolicy")

if [ "${result}" = "RequiredDataOnly" ]; then
	/bin/echo "MAU AcknowledgedDataCollectionPolicy successfully set to RequiredDataOnly for ${loggedInUser}"
	exit 0
else
	/bin/echo "WARNING: MAU AcknowledgedDataCollectionPolicy is ${result} for ${loggedInUser}. Required Data Notice will be shown to user on first launch of MAU."
	exit 1
fi
