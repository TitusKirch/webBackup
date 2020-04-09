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

Then copy the example configuration and make the appropriate settings.
```BASH
cp webBackup.config.example webBackup.config && nano webBackup.config
```

Install webBackup
```BASH
./webBackup.sh --install
```

## Update

To update webBackup, execute the following command.
```BASH
./webBackup.sh --update
```

## How to use

There are two types of backups, incremental and full backups. In both cases, the database (if specified) is stored completely. With incremental backups, changed files are stored temporarily on the same host system (there is only one backup of them at a time). With full backups, an incremental backup is created and packed into an archive with the database backup and additionally saved (these are not deleted or overwritten). Full backups can also be transferred to other servers via SSH.

Creating an incremental backup:
```BASH
# long command
./webBackup.sh --increment

# short command
./webBackup.sh -i
```

Creating a full backup (without storage via SSH on another host system):
```BASH
# long command
./webBackup.sh --full

# short command
./webBackup.sh -f
```

Creating an full backup (with storage via SSH on another host system):
```BASH
# long command
./webBackup.sh --full --ssh

# short command
./webBackup.sh -f -s
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

