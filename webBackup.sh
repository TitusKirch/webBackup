#!/bin/bash

# default config (DO NOT EDIT)
database_name=
file_path=
backup_to_path=

# load config
echo 'Load config...'
if test -f "webBackup.config"
then
    . webBackup.config
	echo 'Success'
else
    echo "Error: No config file found!"
    exit 1
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
    wget --quiet --output-document="$0.tmp" https://raw.githubusercontent.com/TitusKirch/webBackup/master/webBackup
    mv $0.tmp $0
	echo 'Success'
}
function backup_database {
    if [ $database_name != '' ]
    then
        # save database
        echo 'Save database...'
        mysqldump --single-transaction --skip-lock-tables --net_buffer_length 16384 -u root $database_name > $backup_database_path/$datetime.sql
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

# check mode
case $1 in 
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