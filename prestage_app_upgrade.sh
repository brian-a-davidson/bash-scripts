#!/bin/bash
# Script Name: prestage_app_upgrade.sh
# Developer: Brian Davidson
# Purpose: Prestages software (java/tomcat/umb) for UMB application upgrades
# Version: 1.5

# Error OUTPUT-COLORING
red='\e[0;31m'
yellow='\e[33;40m'
white='\e[37;40m'
NC='\e[0m' # No Color


# Variables
app_list=('CNG','PAL','CCH','EC','NIS','PRODCAT','OMS','CPA','VANTIV','NCS','CDCS')
software_dir="/opt/software"
cts_dir="/opt/cts"
tmp_dir="/tmp"
java_home=$(find $cts_dir -maxdepth 1 -type d -name "jdk1*" | sort -n | tail -1 )
today_date=$(date +%m%d%Y)



#### Java Start ###############################################################################################################
read -r -p "Do you want to install a new version of java [Y/N]:"  java_response
        if [[ $java_response =~ ^([yY][eE][sS]|[yY])$ ]]
                then
                        read -r -p "Which version of java do you want to install [example: 8u112]: " new_java_version
                        java_major=$(cut -d'u' -f1 <<< "$new_java_version")
                        java_minor=$(cut -d'u' -f2 <<< "$new_java_version")
                        java_version="*jdk*$java_major*$java_minor*"
                new_java_tar=$(find $software_dir -type f -name "$java_version".gz -mtime -30 -printf "%f\n")
                new_java_tar_dir=$(find $software_dir -type f -name "$java_version".gz -mtime -30)
                existing_java_dir=$(find $cts_dir -maxdepth 1 -type d -name "$java_version")
                install_java="true"
        fi



# Check if java softare is in /tmp instead of software
if [ -n "$install_java" ] && [ -z "$new_java_tar" ]
        then
        new_java_tar=$(find $tmp_dir -type f -name "$java_version".gz -mtime -30 -printf "%f\n" | sort -n | head -1)
        new_java_tar_dir=$(find $tmp_dir -type f -name "$java_version".gz -mtime -30 | sort -n | head -1)
                if [ -n $new_java_tar_dir ]
                        then
                        chown ctsapp:ctsapp $new_java_tar_dir
                fi
fi


# If java directory doesn't already exist then unzip java
if [ ! -d "$existing_java_dir" ] && [ -n "$new_java_tar" ] && [ -n "$install_java" ]
        then
                read -r -p "Do you want to proceed to install $new_java_tar into $cts_dir directory [Y/N]:"  response
                if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
                        then
                        echo "Unziping the java tar file into $cts_dir"
                        cd $cts_dir
                        tar -xvzf $new_java_tar_dir
                        echo "Java successfully unziped"
                        new_java_dir=$(find $cts_dir -maxdepth 1 -type d -name "$java_version")
                        chown -R ctsapp:ctsapp $new_java_dir
                        echo -e "${white}Display the new java directory to verify changes ${NC}"
                                                ls -l $cts_dir
                        echo "Current Directory: $cts_dir"
                        java_installed="true"
                fi
        elif [ -d "$existing_java_dir" ]
                then
                echo -e "${yellow}WARNING:Java Version: $new_java_version has already been installed at $existing_java_dir ${NC}"
                install_java=""
        elif [ -n "$install_java" ]
                then
                echo -e "${red}ERROR: no new java installation files not found $software_dir ${NC}"
                install_java=""
fi

#### Java End ###################################################################################################################


#### Tomcat Start ###############################################################################################################

# Unzip new tomcat version
read -r -p "Do you want to install a new version of tomcat [Y/N]:"  tomcat_response
        if [[ $tomcat_response =~ ^([yY][eE][sS]|[yY])$ ]]
                then
                        read -r -p "Which version of tomcat do you want to install [example: 8u28]: " new_tomcat_version
                        tomcat_major=$(cut -d'u' -f1 <<< "$new_tomcat_version")
                        tomcat_minor=$(cut -d'u' -f2 <<< "$new_tomcat_version")
                        tomcat_version="*tomcat*$tomcat_major*$tomcat_minor*"
                new_tomcat_tar=$(find $software_dir -type f -name "$tomcat_version".gz -mtime -30 -printf "%f\n")
                new_tomcat_tar_dir=$(find $software_dir -type f -name "$tomcat_version".gz -mtime -30)
                existing_tomcat_dir=$(find $cts_dir -maxdepth 1 -type d -name "$tomcat_version")
                install_tomcat="true"
        fi

# Check if tomcat softare is in /tmp instead of software
if [ -n "$install_tomcat" ] && [ -z "$new_tomcat_tar" ]
        then
        new_tomcat_tar=$(find $tmp_dir -type f -name "$tomcat_version".gz -mtime -30 -printf "%f\n" | sort -n | head -1)
        new_tomcat_tar_dir=$(find $tmp_dir -type f -name "$tomcat_version".gz -mtime -30 | sort -n | head -1)
                if [ -n $new_tomcat_tar_dir ]
                        then
                        chown ctsapp:ctsapp $new_tomcat_tar_dir
                fi
fi


# If tomcat directory doesn't already exist then unzip tomcat
if [ ! -d "$existing_tomcat_dir" ] && [ -n "$new_tomcat_tar" ] && [ -n "$install_tomcat" ]
        then
                read -r -p "Do you want to proceed to install $new_tomcat_tar into /opt/cts/ directory [Y/N]:"  response
                if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
                        then
                        echo "Unziping the tomcat tar file into $cts_dir"
                        cd $cts_dir
                        tar -xvzf $new_tomcat_tar_dir
                        echo "Tomcat successfully unziped"
                        new_tomcat_dir=$(find $cts_dir -maxdepth 1 -type d -name "$tomcat_version")
                        chown -R ctsapp:ctsapp $new_tomcat_dir
                        echo -e "${white}Display the new tomcat directory to verify changes ${NC}"
                        ls -l $cts_dir
                        echo "Current Directory: $cts_dir"
                        tomcat_installed="true"
                fi
        elif [ -d "$existing_tomcat_dir" ]
                then
                echo -e "${yellow}WARNING:Java Version: $new_tomcat_version has already been installed at $existing_tomcat_dir ${NC}"
                install_tomcat=""
        elif [ -n "$install_tomcat" ]
                then
                echo -e "${red}ERROR: no new tomcat installation files not found $software_dir ${NC}"
                install_tomcat=""
fi

#### Tomcat End ###############################################################################################################



#### Application Start ###############################################################################################################

# Get Application Name for Upgrade
read -p 'What application is being upgraded: ' app_name
app_upper=$(echo $app_name | awk '{print toupper($0)}')
app_lower=$(echo $app_name | awk '{print tolower($0)}')


#Note: the following can be used instead on new versions of centos
#app_upper=${app_name^^}
#app_lower=${app_name,,}

# Set Java Home
java_home=$(find $cts_dir -maxdepth 1 -type d -name "jdk1*" | sort -n | tail -1 )


# Check if application is already prestaged
new_app_dir="${app_lower}_new_build"
if [ -d "$cts_dir/$new_app_dir" ]
        then
                        echo -e "${yellow}WARNING: The $new_app_dir directory already exits${NC}"
                        app_dir_exists="true"
fi


# Verify it is a valid application name
if [[ ${app_list[*]} =~ ${app_upper} ]]
        then

                read -r -p "Are you sure you want to prestage the upgrade for $app_name [Y/N]:"  response
                if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
                        then
                                app_name_dir="$cts_dir/$app_name"
                                app_install="true"
                fi
        else
                echo -e "${red}ERROR: That is not a valid option. Try again and use one of the options below ${NC}"
                echo "Application Names: CNG, PAL, CCH, EC, NIS, PRODCAT, OMS, CPA, VANTIV, NCS, CDCS"
                exit
fi


# Change variable for ncs to nbms
if [ ${app_lower} = "ncs" ]
        then
        app_upper="NBMS"
        cts_dir="/opt/bea"
        app_name_dir="$cts_dir/$app_name"
fi

# Chage variable for cch to clearinghouse
if [ ${app_lower} = "cch" ]
        then
        app_lower="clearinghouse"
fi

#### Tomee Start ############################
# Check if Tomee needs to be installed for NCS
if [ -n "$app_install" ] && [ ${app_lower} = "ncs" ]
then
read -r -p "Do you need to install Tomee with this version of NCS [Y/N]:"  tomee_response
		if [[ $tomee_response =~ ^([yY][eE][sS]|[yY])$ ]]
                then
                        read -r -p "Which version of tomee do you want to install [example: 7u1]: " new_tomee_version
                        tomee_major=$(cut -d'u' -f1 <<< "$new_tomee_version")
                        tomee_minor=$(cut -d'u' -f2 <<< "$new_tomee_version")
                        tomee_version="*tomee*$tomee_major*$tomee_minor*"
				cts_dir="/opt/cts"
				app_upper="NCS"
				app_lower="nbms"
                new_tomee_tar=$(find $software_dir -type f -name "$tomee_version".zip -mtime -30 -printf "%f\n")
                new_tomee_tar_dir=$(find $software_dir -type f -name "$tomee_version".zip -mtime -30)
                existing_tomee_dir=$(find $cts_dir -maxdepth 1 -type d -name "$tomee_version")
                install_tomee="true"
        fi		
fi		

# If tomee directory doesn't already exist then unzip tomee
if [ ! -d "$existing_tomee_dir" ] && [ -n "$new_tomee_tar" ] && [ -n "$install_tomee" ]
        then
                read -r -p "Do you want to proceed to install $new_tomee_tar into $cts_dir directory [Y/N]:"  response
                if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
                        then
                        echo "Unziping the tomee tar file into $cts_dir"
                        cd $cts_dir
                        unzip $new_tomee_tar_dir
                        echo "tomee successfully unziped"
                        new_tomee_dir=$(find $cts_dir -maxdepth 1 -type d -name "$tomee_version")
                        chown -R ctsapp:ctsapp $new_tomee_dir
                        echo -e "${white}Display the new tomee directory to verify changes ${NC}"
                                                ls -l $cts_dir
                        echo "Current Directory: $cts_dir"
                        tomee_installed="true"
                fi
        elif [ -d "$existing_tomee_dir" ]
                then
                echo -e "${yellow}WARNING:tomee Version: $new_tomee_version has already been installed at $existing_tomee_dir ${NC}"
                install_tomee=""
        elif [ -n "$install_tomee" ]
                then
                echo -e "${red}ERROR: no new tomee installation files not found $software_dir ${NC}"
                install_tomee=""
fi

#### Tomee End ############################	
		
#### Application Continue #################		

# Check for latest software in software directory (modified time)
app_version=$(find $software_dir -maxdepth 1 -type d -name "*${app_upper}*" -mtime -30 -printf "%f\n" | sort -n | head -1)


# Check if lastest software in software directory (access time)
if [ -z "$app_version" ]
        then
		app_version=$(find $tmp_dir -maxdepth 1 -type d -name "*${app_upper}*" -atime -30 -printf "%f\n" | sort -n | head -1)
fi


# Check if lastest software in tmp directory
if [ -z "$app_version" ]
        then
        app_version=$(find $tmp_dir -maxdepth 1 -type d -name "*${app_upper}*" -mtime -30 -printf "%f\n" | sort -n | head -1)	
fi


# Verify software is found
if [ -z "$app_version" ] && [ -n "$app_install" ]
        then
                echo -e "${red}ERROR: $app_name software not found $software_dir. Please ensure software is located in that directory ${NC}"
                exit
fi


# Verify if user wants to use latest software uploaded
if [ -n "$app_install" ]
        then
        read -r -p "Do you want to install the following $app_name version <$app_version> [Y/N]:"  response
        if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
                then
                        echo "Version: $app_version has been selected"
                        chown -R ctsapp:ctsapp $software_dir/$app_version/
                else
                        read -r -p "Which version of $app_name do you want to install:" response
                        app_version=$(find $software_dir -maxdepth 1 -type d -name "*$response*" -printf "%f\n")

                        if [ -z "$app_version" ] && [ -z "$app_install" ]
                                then
                                echo -e "${red}ERROR: $app_name software not found $software_dir ${NC}"
                                exit
                        fi
                        read -r -p "Do you want to install the following $app_name version <$app_version> [Y/N]:"  response
                                if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
                                        then
                                        echo "Version: $app_version has been selected"
                                        chown -R ctsapp:ctsapp $software_dir/$app_version/
                                else
                                        echo -e "${red}ERROR: No version selected ${NC}"
                                        exit
                                fi
        fi
fi

# Create a new directory for new software
if [ -n "$app_install" ]
        then
        new_app_dir="${app_lower}_new_build"
        echo "Creating a new directory called $new_app_dir in $cts_dir directory"
        mkdir $cts_dir/$new_app_dir
        chown -R ctsapp:ctsapp $cts_dir/$new_app_dir/
fi

if [ -d "$cts_dir/$new_app_dir" ] && [ -n "$app_install" ]
        then
                echo -e "${white}The $new_app_dir directory has been created in $cts_dir ${NC}"
fi

# Unzip software into new directory
zip_file=$(find $software_dir/$app_version -type f -name '*.zip' -printf "%f\n")
zip_dir=$(find $software_dir/$app_version -type f -name '*.zip')
full_new_app_dir=$cts_dir/$new_app_dir

#echo "zip file = $zip_file"
#echo "zip dir = $zip_dir"


# Untar applications if selected
if [ -n "$app_install" ] && [ ${app_lower} != "ncs" ]
then
read -r -p "Do you want to proceed with unzipping $zip_file from $app_version into $new_app_dir [Y/N]:"  response
        if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]] && [ -n "$java_home" ]
                then
                        cd $cts_dir/$new_app_dir/
                        echo "Running tar command from java version: $java_home"
                        $java_home/bin/jar xvf $zip_dir
                        chown -R ctsapp:ctsapp $cts_dir/$new_app_dir/
                        echo "** Unzip COMPLETE **"
                        cp -p $app_name_dir/install-unix.properties $full_new_app_dir/install-unix.properties_previous
                        echo "Display $new_app_dir directory"
                        pwd
                        ls -latr $cts_dir/$new_app_dir
                        app_prestaged="true"
                else
                        echo -e "${red}ERROR: Ensure java is installed in $cts_dir and rerun this script to prestage $app_name ${NC}"
        fi
fi

# Unzip NCS application if selected
if [ -n "$app_install" ] && [ ${app_lower} = "ncs" ]
then
read -r -p "Do you want to proceed with unzipping $zip_file from $app_version into $new_app_dir [Y/N]:"  response
        if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
                then
                        cd $cts_dir/$new_app_dir/
                        echo "zip dir2 = $zip_dir"
                        echo "Running tar command from java version: $java_home"
                        $java_home/bin/jar xvf $zip_dir
                        chown -R ctsapp:ctsapp $cts_dir/$new_app_dir/
                        echo "** Unzip COMPLETE **"
                        cp -p $app_name_dir/install-unix.properties $full_new_app_dir/install-unix.properties_previous
                        echo -e "${white}Display $new_app_dir directory to verify changes ${NC}"
                        pwd
                        ls -latr $cts_dir/$new_app_dir
                        app_prestaged="true"
                else
                        echo -e "${red}ERROR: Ensure java is installed in $cts_dir and rerun this script to prestage $app_name ${NC}"
        fi
fi


#### Application End ###############################################################################################################


#### Summary Start #################################################################################################################

# Check to see if Application was prestaged
if [ -n "$app_prestaged" ]
        then
        app_prestaged="$app_name software has been prestaged"
        tasks_complete="$app_prestaged"
fi

# Check to see if Java was installed
if [ -n "$java_installed" ]
        then
        java_installed="Java version $new_java_version has been installed"
        tasks_complete="$tasks_complete\n$java_installed"
fi


# Check to see if Java was installed
if [ -n "$tomcat_installed" ]
        then
        tomcat_installed="Tomcat version $new_tomcat_version has been installed"
        tasks_complete="$tasks_complete\n$tomcat_installed"
fi


# Display completed tasks from script
if [ -n "$app_prestaged" ] || [ -n "$java_installed" ] || [ -n "$tomcat_installed" ]
        then
                echo -e "${white}Display the CTS directory to verify changes ${NC}"
                ls -l $cts_dir
        echo -e "${white}The following tasks have been completed ${NC}"
        echo -e "$tasks_complete"
        echo "Pre-staging Complete!"

                else
                        echo "Pre-staging Complete"
                        echo "No changes were made"
fi

#### Summary End ############################################################################################################
