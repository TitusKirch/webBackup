#!/bin/bash

# get current path and switch to it
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR

# get url from repository
URL=https://raw.githubusercontent.com/TitusKirch/webBackup/master

# check for test mode
if test -f "testMode"
then
    test_mode=true
    echo "Info: Script is executed in test mode"
else
    test_mode=false
fi

# functions
function load_config {
	echo "Load config..."
	if test -f "webBackup.config"
	then
	    . webBackup.config
		echo "Success: Loading process completed"
	else
	    echo "Error: It seems that webBackup has not yet been set up. Please run './webBackup.sh --setup'."
	    exit 1
	fi

    # if dev mode enabled, update url
    if [ -n "$dev_mode"] && [ "$dev_mode" == "true" ]
    then
        URL=https://raw.githubusercontent.com/TitusKirch/webBackup/dev
        echo "Info: Change to the developer branch"
    fi
}
function check_required_config {
    # backup_database
    if [ -z "$backup_database" ] || [ "$backup_database" == "" ]
    then
	    echo "Error: The following required setting is missing in the configuration file 'backup_database'."
	    exit 1
    fi

    # backup_file_path
    if [ -z "$backup_file_path" ] || [ "$backup_file_path" == "" ]
    then
	    echo "Error: The following required setting is missing in the configuration file 'backup_file_path'."
	    exit 1
    fi

    # backup_hourly
    if [ -z "$backup_hourly" ] || [ "$backup_hourly" == "" ]
    then
	    echo "Error: The following required setting is missing in the configuration file 'backup_hourly'."
	    exit 1
    fi

    # backup_daily
    if [ -z "$backup_daily" ] || [ "$backup_daily" == "" ]
    then
	    echo "Error: The following required setting is missing in the configuration file 'backup_daily'."
	    exit 1
    fi

    # backup_weekly
    if [ -z "$backup_weekly" ] || [ "$backup_weekly" == "" ]
    then
	    echo "Error: The following required setting is missing in the configuration file 'backup_weekly'."
	    exit 1
    fi

    # backup_monthly
    if [ -z "$backup_monthly" ] || [ "$backup_monthly" == "" ]
    then
	    echo "Error: The following required setting is missing in the configuration file 'backup_monthly'."
	    exit 1
    fi
}
function webBackup_setup {
    # start
    echo "Start setup..."
    
    # download example config
    echo "Download example config..."
    if [ $test_mode == true ]
    then
        echo "Info: Download is not executed (test mode activated)"
    else
        wget --quiet --output-document=webBackup.config.example $URL/webBackup.config.example
    fi
    echo "Success: Download completed"

    # check if config file exist
    if test -f "webBackup.config"
    then
        echo "Info: Configuration file was found"
    else
        echo "Info: Configuration file was not found"

        # copy example config
        echo "Copy example config..."
        cp webBackup.config.example webBackup.config
        echo "Success: Copying completed"
    fi

    # end
    echo "Success: Setup completed"
}
function webBackup_install {
    echo "TEST"
}
function webBackup_update {
    # start
    echo "Start update..."
    
    # download example config
    echo "Download example config..."
    if [ $test_mode == true ]
    then
        echo "Info: Download is not executed (test mode activated)"
    else
        wget --quiet --output-document=webBackup.config.example $URL/webBackup.config.example
    fi
    echo "Success: Download completed"

    # end
    echo "Success: Update completed"
}
function test_mode {
    # check if config file exist
    if [ $test_mode == true ]
    then
        echo "Info: Test mode file was found"
    else
        echo "Info: Test mode file was not found"

        # create test mode file
        echo "Create test mode file..."´
        touch testMode
        echo "Success: Creation completed"
    fi
}


#  setup variables
#datetime=$(date +%Y-%m-%d_%H-%M-%S)
#backup_path=$backup_to_path/webBackup
#files_folder=files
#database_folder=database
#backup_files_path=$backup_path/$files_folder
#backup_database_path=$backup_path/$database_folder
#backup_full_path=$backup_path/full

# functions

#function install_script {
#    # setup webBackup folder structure
#    echo 'Create webBackup folder structure...'
#    mkdir -p $backup_path
#    mkdir -p $backup_files_path
#    mkdir -p $backup_database_path
#    mkdir -p $backup_full_path
#    echo 'Success'
#}
#function update_script {
#    # update webBackup script
#    echo 'Update script...'
#    wget --quiet --output-document=$0.tmp $URL/webBackup.sh
#    wget --quiet --output-document=webBackup.config.example $URL/webBackup.config.example
#    chmod +x $0.tmp
#    mv $0.tmp $0
#	echo 'Success'
#}

# check mode
case $1 in 
    "--setup" )
        webBackup_setup
        ;;
    "--install" )
        webBackup_update
        check_required_config
        webBackup_install
        ;;
    "--update" )
        webBackup_update
        ;;
    #"--full"|"-f" )
    #    if [ $2 == "--ssh" ] || [ $2 == "-s" ]
    #    then
    #        ssh_upload
    #    fi
    #    ;;
    #"--increment"|"-i" )
    #    ;;
    "--test" )
        load_config
        check_required_config
        ;;
    "--testmode" )
        load_config
        test_mode
        ;;
    *)
        echo "Error: Your input was incorrect, please have a look at the list of all commands here: https://github.com/TitusKirch/webBackup/wiki/Commands"
        exit 1
        ;;
esac
