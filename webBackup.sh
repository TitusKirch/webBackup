#!/bin/bash

# default config (DO NOT EDIT)
database_name=
file_path=
backup_to_path=
ssh_user=
ssh_port=
ssh_destination=

# get script directory and go to it
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR

# load config if not setup
if [ $1 != "--setup" ]
then
	echo 'Load config...'
	if test -f "webBackup.config"
	then
	    . webBackup.config
		echo 'Success'
	else
	    echo "Error: No config file found! Copy the default one with 'cp webBackup.config.example webBackup.config'"
	    exit 1
	fi
fi

# setup
datetime=$(date +%Y-%m-%d_%H-%M-%S)
backup_path=$backup_to_path/webBackup
files_folder=files
database_folder=database
backup_files_path=$backup_path/$files_folder
backup_database_path=$backup_path/$database_folder
backup_full_path=$backup_path/full

# functions
function setup_script {
    # setup webBackup
    echo 'Download example config...'
    wget --quiet --output-document=webBackup.config.example https://raw.githubusercontent.com/TitusKirch/webBackup/master/webBackup.config.example
    echo 'Success'
}
function install_script {
    # setup webBackup folder structure
    echo 'Create webBackup folder structure...'
    mkdir $backup_path
    mkdir $backup_files_path
    mkdir $backup_database_path
    mkdir $backup_full_path
    echo 'Success'
}
function update_script {
    # update webBackup script
    echo 'Update script...'
    wget --quiet --output-document=$0.tmp https://raw.githubusercontent.com/TitusKirch/webBackup/master/webBackup.sh
    wget --quiet --output-document=webBackup.config.example https://github.com/TitusKirch/webBackup/blob/master/webBackup.config.example
    chmod +x $0.tmp
    mv $0.tmp $0
	echo 'Success'
}
function backup_database {
    if [ $database_name != '' ]
    then
        # save database
        echo 'Save database...'
        mysqldump --complete-insert --routines --triggers --single-transaction --skip-lock-tables --net_buffer_length 16384 -u root $database_name > $backup_database_path/$datetime.sql
		cp $backup_database_path/$datetime.sql $backup_database_path/last.sql
        echo 'Success'
    fi
}
function backup_files {
    if [ $file_path != '' ]
    then
        # save files
        echo 'Save files...'
		rsync -a $file_path/ $backup_files_path
        echo 'Success'
    fi
}
function backup_full {
    # create full backup
    echo 'Create full backup...'
	rm -r -f $backup_path/tmp
	mkdir $backup_path/tmp
	mkdir $backup_path/tmp/$files_folder
	mkdir $backup_path/tmp/$database_folder
	cp $backup_database_path/last.sql $backup_path/tmp/$database_folder/database.sql
	cp -a $backup_files_path/* $backup_path/tmp/$files_folder/
	tar -zcf $backup_full_path/$datetime.tar.gz -C $backup_path/tmp .
	rm -r -f $backup_path/tmp
    echo 'Success'
    echo 'Backup available at '$backup_full_path/$datetime.tar.gz
}
function ssh_upload {
    # check for ssh transfer
    if [ $ssh_user != '' ]
    then
        if [ $ssh_port != '' ]
        then
            if [ $ssh_destination != '' ]
            then
                scp -P $ssh_port $backup_full_path/$datetime.tar.gz $ssh_user@$ssh_destination
            else
                echo "Error: No ssh destination is set"
                exit 1
            fi
        else
            echo "Error: No ssh port is set"
            exit 1
        fi
    else
        echo "Error: No ssh user is set"
        exit 1
    fi
}

# check mode
case $1 in 
    "--setup" )
        setup_script
        ;;
    "--install" )
        install_script
        ;;
    "--update" )
        update_script
        ;;
    "--full"|"-f" )
        backup_database
		backup_files
		backup_full
        if [ $2 == "--ssh" ] || [ $2 == "-s" ]
        then
            ssh_upload
        fi
        ;;
    "--increment"|"-i" )
        backup_database
		backup_files
        ;;
    *)
        echo "Error: Use "$0" (--install) || (--full || -f ) || (--increment || -i)"
        exit 1
        ;;
esac
