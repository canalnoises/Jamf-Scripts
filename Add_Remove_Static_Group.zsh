#!/bin/zsh

# Run on a computer to add it to or remove it from a specific Static Computer Group in Jamf Pro
# Isaac Nelson 14 Aug 2019
#	30 Dec 2019 - Tested with zsh and updated shebang
#	04 Feb 2020 - Added jamf manage

# Usage: 
# 	Add this script to Jamf Pro. Name Parameter 4 to "Static group name" and Parameter 5 to "+ (add) or - (remove)"
# 	When using it in a policy or in Jamf Remote, enter the exact name of the static group in the "Static group name" field
#		and either "+" to add the comptuer to the staic group or "-" to remove it in the add/remove field.
#	Put credentials for an account with permissions to Read and Update static computer groups and Read computers in the variables below.

# Jamf Pro user account with permissions to Read and Update static computer groups and Read computers
uservar="username"
passvar="password"

##############  NO NEED TO EDIT BELOW THIS LINE  ##############

action="${5}" # Script parameter 5: "Add (+) or Remove (-)"

if [[ ${action} == "+" ]]; then
	addOrDelete="additions"
elif [[ ${action} == "-" ]]; then
	addOrDelete="deletions"
else
	/bin/echo "Action must be either + or -"
	exit 1
fi

jamfURL=$(/usr/bin/defaults read /Library/Preferences/com.jamfsoftware.jamf.plist jss_url)



groupName="${4}" # Script Parameter 4: Static group name as it appears in Jamf Pro
groupNameURL=$(/usr/bin/python -c "import urllib; print urllib.quote('''${groupName}''')") # URL-encoded static group name - https://stackoverflow.com/a/2236014

serialNumber=$(/usr/sbin/ioreg -c IOPlatformExpertDevice -d 2 | /usr/bin/awk -F\" '/IOPlatformSerialNumber/{print $(NF-1)}')

xmlResponse=$(/usr/bin/curl -sk -H "accept: application/xml" -u ${uservar}:${passvar} ${jamfURL}/JSSResource/computers/serialnumber/${serialNumber} -X GET)
computerName=$(/usr/bin/xmllint --xpath "/computer/general/name/text()" - <<<"${xmlResponse}")
computerID=$(/usr/bin/xmllint --xpath "/computer/general/id/text()" - <<<"${xmlResponse}")

/usr/bin/curl -sk -H "Content-Type: text/xml" -u ${uservar}:${passvar} ${jamfURL}/JSSResource/computergroups/name/${groupNameURL} -X PUT -d "<computer_group><name>${groupName}</name><computer_${addOrDelete}><computer><id>${computerID}</id><name>${computerName}</name></computer></computer_${addOrDelete}></computer_group>"

/usr/local/bin/jamf recon
/usr/local/bin/jamf manage

exit 0
