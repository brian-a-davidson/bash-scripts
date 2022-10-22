#!/bin/sh
# Script Name: settlement_file_monitor.sh
# Developer: Brian Davidson
# Purpose: Send an email if settlement file has been received for the day
# Version: 1.0

# Local Date Variables
year=$(date +%Y)
serverdate=$(date +%Y%m%d)
yesterday=$(date --date="yesterday" +"%F")

# Local File Variables
filename="$serverdate*SETTLEMENT*.csv"
file_list_name=/opt/monitor_scripts/config_files/gs_sfile_list.txt
file_list_name_yt=/opt/monitor_scripts/config_files/gs_sfile_list_yesterday.txt
service_message=/opt/monitor_scripts/config_files/service_desk_message.txt
dir="/shared/sftp/metraprod/files"

# Local Email Variables
sender_email="brian.allan.davidson@gmail.com"
email_list="brian.allan.davidson@gmail.com"

# Local Fail Email Variables
fail_sender="brian.allan.davidson@gmail.com"
fail_email_list="brian.allan.davidson@gmail.com"

# Log yesterdays file
cat $file_list_name > $file_list_name_yt

# Find files and add to file list
file_list=$(find $dir -maxdepth 1 -name $filename -type f -newermt $yesterday -printf "%f\n")
echo "$file_list" > $file_list_name

# Check file count
filecount=$(find $dir -maxdepth 1 -name $filename -type f -newermt $yesterday -printf "%f\n" | wc -l)

if [[ "$filecount" -eq 0 ]]; then
        subject="P1: FAILED - NO Settlement file received for $serverdate - File Count:$filecount"
	cat $file_list_name_yt >> $service_message
        cat $service_message | mail -r $fail_sender -s "$subject" $fail_email_list 
	sed -i '/Latest reports received/q' $service_message
else
        subject="SUCCESS - Settlement file received for $serverdate - File Count:$filecount"
        cat $file_list_name | mail -r $sender_email -s "$subject" $email_list 
fi

