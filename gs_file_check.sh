#!/bin/sh
# Script Name: gs_file_check.sh
# Developer: Brian Davidson
# Purpose: Send success email if all 3 files have been recieved otherwise send a failure email
# Version: 1.0

# Local File Variables 
config_file=/opt/monitor_scripts/config_files/gs_file_config.txt
file_list_name=/opt/monitor_scripts/config_files/gs_file_list.txt
file_list_name_yt=/opt/monitor_scripts/config_files/gs_file_list_yesterday.txt
service_message=/opt/monitor_scripts/config_files/service_desk_message.txt

# Local Email Variables
sender_email="brian.allan.davidson@gmail.com"
email_list="brian.allan.davidson@gmail.com"

# Local Fail Email Variables
fail_sender="brian.allan.davidson@gmail.com"
fail_email_list="brian.allan.davidson@gmail.com"

# Get Remote Variables
filedate=$(sed -n 's/DATE=//p' $config_file) 
fileemail=$(sed -n 's/EMAIL=//p' $config_file)
filecount=$(sed -n 's/FILECOUNT=//p' $config_file)
clear="0"

if [[ "$filecount" -ge 3 ]]; then
        subject="SUCCESS - ALL GlobeSherpa Sales files received for $filedate - File Count:$filecount"
        cat $file_list_name | mail -r $sender_email -s "$subject" $email_list
        cat $file_list_name > $file_list_name_yt
        sed -i "s/FILECOUNT=$filecount/FILECOUNT=$clear/g" $config_file
        sed -i "s/EMAIL=$fileemail/EMAIL=$clear/g" $config_file
        sed -i "s/DATE=$filedate/DATE=$clear/g" $config_file
else
        subject="P1: FAILED - NOT ALL 3 GlobeSherpa Sales files received for $filedate - File Count:$filecount"
	cat $file_list_name >> $service_message
        cat $file_list_name_yt >> $service_message
	cat $service_message | mail -r $fail_sender -s "$subject" $fail_email_list
	cat $file_list_name > $file_list_name_yt
        sed -i "s/FILECOUNT=$filecount/FILECOUNT=$clear/g" $config_file
        sed -i "s/EMAIL=$fileemail/EMAIL=$clear/g" $config_file
        sed -i "s/DATE=$filedate/DATE=$clear/g" $config_file
	sed -i '/Latest reports received/q' $service_message
fi
