# webBackup
<p align="center">
    <a href="https://github.com/TitusKirch/webBackup/blob/master/LICENSE"><img src="https://img.shields.io/github/license/TitusKirch/webBackup?label=License&labelColor=30363D&color=2FBF50" alt="License"></a>
    <a href="https://github.com/TitusKirch/webBackup/releases"><img src="https://img.shields.io/github/downloads/TitusKirch/webBackup/total?label=Downloads&labelColor=30363D&color=2FBF50" alt="Downloads"></a>
    <a href="https://github.com/TitusKirch/webBackup/graphs/contributors"><img src="https://img.shields.io/github/contributors/TitusKirch/webBackup?label=Contributors&labelColor=30363D&color=2FBF50" alt="Contributors"></a>
    <a href="https://discord.tkirch.dev"><img src="https://img.shields.io/discord/576562577769889805?label=Discord&labelColor=30363D&color=2FBF50&logoColor=959DA5&logo=Discord" alt="Discord"></a>
</p>

## Table of contents

* [About the project](#about-the-project)
* [Install](#install)
* [Update](#update)
* [How to use](#how-to-use)
* [Contributing](#contributing)
* [Versioning](#versioning)
* [Authors](#authors)
* [License](#license)

## About the project

webBackup should become a feature-rich, automated and customizable backup script for web applications.

## Install

The following command downloads the latest version of the script to the current directory and runs the setup.
```BASH
wget https://raw.githubusercontent.com/TitusKirch/webBackup/master/webBackup.sh && chmod +x webBackup.sh && ./webBackup.sh --setup
```

Then configure webBackup with your favorite editor (here the command with nano).
```BASH
nano webBackup.config
```

Then install webBackup (during installation webBackup will be updated again).
```BASH
./webBackup.sh --install
```

Here the whole installation process in one line
```BASH
wget https://raw.githubusercontent.com/TitusKirch/webBackup/master/webBackup.sh && chmod +x webBackup.sh && ./webBackup.sh --setup && nano webBackup.config && ./webBackup.sh --install
```

## Update

To update webBackup, execute the following command.
```BASH
./webBackup.sh --update
```

## How to use

webBackup creates a local copy of your database and/or files.
Optional hourly (maximum 24), daily (maximum 7), weekly (maximum 5) or monthly (maximum 12) backup archives can be created. **Important**: Old backups will be overwritten.
Furthermore there is the possibility to save backups additionally via ssh on another server.

Update backup files:
```BASH
# long command
./webBackup.sh --backup

# short command
./webBackup.sh -b
```

Create a backup archive (optinal with transmission via ssh):
```BASH
# long command
./webBackup.sh --archive-backup --hourly|--daily|--weekly|--monthly

# short command
./webBackup.sh -ab -h|-d|-w|-m

# long command with transmission via ssh
./webBackup.sh --archive-backup --hourly|--daily|--weekly|--monthly --ssh

# short command with transmission via ssh
./webBackup.sh -ab -h|-d|-w|-m -s
```

Update the backup files and create a backup archive (optinal with transmission via ssh):
```BASH
# long command
./webBackup.sh --archive-backup-complete --hourly|--daily|--weekly|--monthly

# short command
./webBackup.sh -abc -h|-d|-w|-m

# long command with transmission via ssh
./webBackup.sh --archive-backupp-complete --hourly|--daily|--weekly|--monthly --ssh

# short command with transmission via ssh
./webBackup.sh -abc -h|-d|-w|-m -s
```

**Here is an example scenario with conjobs.**
Creates an hourly backup every hour at 10 past 10, a daily backup every day at 02:20, a weekly backup every Monday at 03:30 and a monastic backup every first day of a month at 04:40. Whenever a backup is created, the backup files are updated and a copy is transferred via ssh afterwards. (of course the jwewewilige backup must be activated in the config, despite the cronjob)
```BASH
10 * * * * /path/to/webBackup.sh -abc -h -s >/dev/null 2>&1
20 2 * * * /path/to/webBackup.sh -abc -d -s >/dev/null 2>&1
30 3 * * 1 /path/to/webBackup.sh -abc -w -s >/dev/null 2>&1
40 4 1 * * /path/to/webBackup.sh -abc -d -s >/dev/null 2>&1
```

## Contributing
There are many ways to help this open source project. Write tutorials, improve documentation, share bugs with others, make feature requests, or just write code. We look forward to every contribution.

For more information and our guidelines, please refer to the [CONTRIBUTING.md](CONTRIBUTING.md) file.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For available versions, see the [tags on this repository](https://github.com/TitusKirch/webBackup/tags). 

## Authors

* **Titus Kirch** - *Main development* - [TitusKirch](https://github.com/TitusKirch)

See also the list of [contributors](https://github.com/TitusKirch/webBackup/graphs/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

