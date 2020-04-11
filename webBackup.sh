#!/bin/bash

# get current path and switch to it
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR

# get url from repository
URL=https://raw.githubusercontent.com/TitusKirch/webBackup/master

# check for test mode
if [ -f "testMode" ]
then
    test_mode=true
    echo "Info: Script is executed in test mode"
else
    test_mode=false
fi

# load config
echo "Load config..."
if [ -f "webBackup.config" ]
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

# check backup_path
if [ -z "$backup_path" ] || [ "$backup_path" == "" ]
then
    backup_path=$DIR/webBackup
    echo "Info: backup_path was set to: "$backup_path
fi

# functions
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
    if [ -f "webBackup.config" ]
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
    # start
    echo "Start installation..."

    # check if webBackup folder exists and if so, cancel setup
    if [ -d "$backup_path" ];
    then
	    echo "Error: A webBackup folder already exists, please secure it and remove it before you can reinstall webBackup."
	    exit 1
    fi

    # create webBackup folder structure
    echo 'Create webBackup folder structure...'
    mkdir -p $backup_path
    mkdir -p $backup_path/last
    mkdir -p $backup_path/last/database
    mkdir -p $backup_path/last/files
    mkdir -p $backup_path/archives
    mkdir -p $backup_path/archives/hourly
    mkdir -p $backup_path/archives/daily
    mkdir -p $backup_path/archives/weekly
    mkdir -p $backup_path/archives/monthly
    echo 'Success: Creation completed'

    # end
    echo "Success: Installation completed"
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
    
    # download last webBackup.sh
    echo "Download last webBackup.sh..."
    if [ $test_mode == true ]
    then
        echo "Info: Download is not executed (test mode activated)"
    else
        wget --quiet --output-document=$0.tmp $URL/webBackup.sh
        chmod +x $0.tmp
        mv $0.tmp $0
    fi
    echo "Success: Download completed"

    # end
    echo "Success: Update completed"
}
function backup_last_update {
    # start
    echo "Start backup..."

    # create database backup, if desired
    if [ $backup_database != "false" ]
    then
        echo "Create database backup..."
        mysqldump --complete-insert --routines --triggers --single-transaction --skip-lock-tables --net_buffer_length 16384 -u root $backup_database > $backup_path/last/database/last.sql.tmp
        mv $backup_path/last/database/last.sql.tmp $backup_path/last/database/last.sql
        echo "Success: Database backup"
    fi
    
    # create file backup, if desired
    if [ $backup_file_path != "false" ]
    then
        echo "Create file backup..."
        rsync -a --delete $backup_file_path/ $backup_path/last/files
        echo "Success: File backup"
    fi

    # end
    echo "Success: Backup"
}
function archive_backup {
    # setup
    echo "Start archiving the backup..."
    case $1 in    
        "--hourly"|"-h" )
            archive_backup_path=$backup_path/archives/hourly
            archive_backup_id=$(date +%H)
            archive_prefix=hourly
            ;;
        "--daily"|"-d" )
            archive_backup_path=$backup_path/archives/daily
            archive_backup_id=$(date +%d)
            archive_prefix=daily
            ;;
        "--weekly"|"-w" )
            archive_backup_path=$backup_path/archives/weekly
            archive_backup_id=$((($(date +%-d)-1)/7+1))
            archive_prefix=weekly
            ;;
        "--monthly"|"-m" )
            archive_backup_path=$backup_path/archives/monthly
            archive_backup_id=$(date +%-m)
            archive_prefix=monthly
            ;;
        *)
            echo "Error: Your input was incorrect, please have a look at the list of all commands here: https://github.com/TitusKirch/webBackup/wiki/Commands"
            exit 1
            ;;
    esac

    # get archive backup file path
    archive_backup_file_path=$archive_backup_path/$archive_prefix\_$archive_backup_id.tar.gz
     
    # check if config file exist
    if [ -f "$archive_backup_file_path" ]
    then
        echo "Remove old backup..."
        rm $archive_backup_file_path
        echo "Old backup was removed"
    fi

    # prepare backup
    mkdir -p $backup_path/archives/tmp
    mkdir -p $backup_path/archives/tmp/files
    if [ $backup_database != "false" ]
    then
        echo "Copy last database backup..."
        cp $backup_path/last/database/last.sql $backup_path/archives/tmp/database.sql
        echo "Success: Copy created"
    fi
    if [ $backup_file_path != "false" ]
    then
        echo "Copy last file backup..."
        cp -a $backup_path/last/files/* $backup_path/archives/tmp/files
        echo "Success: Copy created"
    fi

    # cretae archive
    tar -zcf $archive_backup_file_path -C $backup_path/archives/tmp .
    
    # end (except backup should be transferred via ssh)
    echo "Success: Backup created"
    echo "Info: Backup available at '$archive_backup_file_path'"

    # check for transfer via ssh
    if [ "$2" == "--ssh" ] || [ "$2" == "-s" ]
    then
        ssh_transfer $archive_backup_file_path
    fi

    # delete the preparation
	rm -r -f $backup_path/archives/tmp
}
function ssh_transfer {
    # ssh_user
    if [ -z "$ssh_user" ] || [ "$ssh_user" == "" ]
    then
	    echo "Error: The following required setting is missing in the configuration file 'ssh_user'."
	    exit 1
    fi

    # ssh_host
    if [ -z "$ssh_host" ] || [ "$ssh_host" == "" ]
    then
	    echo "Error: The following required setting is missing in the configuration file 'ssh_host'."
	    exit 1
    fi

    # ssh_port
    if [ -z "$ssh_port" ] || [ "$ssh_port" == "" ]
    then
	    echo "Error: The following required setting is missing in the configuration file 'ssh_port'."
	    exit 1
    fi

    # ssh_backup_path
    if [ -z "$ssh_backup_path" ] || [ "$ssh_backup_path" == "" ]
    then
	    echo "Error: The following required setting is missing in the configuration file 'ssh_backup_path'."
	    exit 1
    fi

    # check if file was specified for transmission
    if [ -z "$1" ] || [ "$1" == "" ]
    then
        echo "Error: No file was specified for transmission"
        exit 1
    fi

    # ssh_pub_key_path
    if [ -z "$ssh_pub_key_path" ] || [ "$ssh_pub_key_path" == "" ]
    then
        scp_i=
    else
        scp_i="-i $ssh_pub_key_path "
    fi

    # try to transfer file
    echo "Start to transfer file ('$1')..."
    cp -a $backup_path/last/files/* $backup_path/archives/tmp/files
    scp $scp_i-P $ssh_port $1 $ssh_user@$ssh_host:$ssh_backup_path
    echo "Success: Transfer completed"
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

# check command
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
    "--backup"|"-b" )
        backup_last_update
        ;;
    "--archive-backup"|"-ab" )
        # check mode
        case $2 in    
            "--hourly"|"-h"|"--daily"|"-d"|"--weekly"|"-w"|"--monthly"|"-m" )
                archive_backup $2 $3
                ;;
            *)
                echo "Error: Your input was incorrect, please have a look at the list of all commands here: https://github.com/TitusKirch/webBackup/wiki/Commands"
                exit 1
                ;;
        esac
        ;;
    "--archive-backup-complete"|"-abc" )
        # check mode
        case $2 in    
            "--hourly"|"-h"|"--daily"|"-d"|"--weekly"|"-w"|"--monthly"|"-m" )
                backup_last_update
                archive_backup $2 $3
                ;;
            *)
                echo "Error: Your input was incorrect, please have a look at the list of all commands here: https://github.com/TitusKirch/webBackup/wiki/Commands"
                exit 1
                ;;
        esac
        ;;
    "--test" )
        check_required_config
        ;;
    "--testmode" )
        test_mode
        ;;
    *)
        echo "Error: Your input was incorrect, please have a look at the list of all commands here: https://github.com/TitusKirch/webBackup/wiki/Commands"
        exit 1
        ;;
esac
