#!/bin/sh
# Script Name: gs_file_monitor.sh
# Developer: Brian Davidson
# Purpose: Send an email each time a file has been received for the day
# Version: 1.0

# Local Date Variables 
year=$(date +%Y)
dir="/shared/sftp/metraprod/files"
temp="/tmp"
serverdate=$(date +%Y%m%d)
yesterday=$(date --date="yesterday" +"%F")

# Local File Variables
filename="$year*SALES*.csv"
config_file=/opt/monitor_scripts/config_files/gs_file_config.txt
file_list_name=/opt/monitor_scripts/config_files/gs_file_list.txt

# Local Email Variables
sender_email="test-email@gmail.com"
email_list="test-email@gmail.com"

# Get Remote Variables
filedate=$(sed -n 's/DATE=//p' $config_file)
fileemail=$(sed -n 's/EMAIL=//p' $config_file)
filecount=$(sed -n 's/FILECOUNT=//p' $config_file)

# Update Date in gs_file_config.txt
if [[ "$filecount" -eq 0 ]]
        then
        sed -i "s/DATE=0/DATE=$serverdate/g" $config_file 
fi


# Get Date from gs_file_config.txt
filedate=$(sed -n 's/DATE=//p' $config_file)

# Set file name with date
filename="$filedate*SALES*.csv"

# Find files and add to file list
file_list=$(find $dir -maxdepth 1 -name $filename -type f -newermt $yesterday -printf "%f\n")
echo "$file_list" > $file_list_name

# Update file count variable
new_filecount=$(find $dir -maxdepth 1 -name $filename -type f -newermt $yesterday -printf "%f\n" | wc -l)

# Update file count in count file
sed -i "s/FILECOUNT=$filecount/FILECOUNT=$new_filecount/g" $config_file

# Get file count from count file
filecount=$(sed -n 's/FILECOUNT=//p' $config_file)

# Send emails if files received
if [ "$filecount" -gt "$fileemail" ]; then
                subject="GlobeSherpa Sales files received on $(date +%Y%m%d_%H%M) - File Count:$filecount"
                cat $file_list_name | mail -r $sender_email -s "$subject" $email_list
                new_email=$[fileemail+1]
                sed -i "s/EMAIL=$fileemail/EMAIL=$new_email/g" $config_file
else
        exit
fi

