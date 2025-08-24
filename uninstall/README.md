# Uninstall Scripts

This directory contains scripts to uninstall tools and applications that were installed using the Ubuntu Installation Kit.

## Usage

### Uninstall All Tools

To uninstall all tools at once, run the main uninstall script:

```bash
chmod +x uninstall_tools.sh
./uninstall_tools.sh
```

### Uninstall Individual Tools

To uninstall a specific tool, run its corresponding uninstall script:

```bash
chmod +x uninstall/uninstall_[tool].sh
./uninstall/uninstall_[tool].sh
```

For example, to uninstall Python:

```bash
./uninstall/uninstall_python.sh
```

## Available Uninstall Scripts

### Development Tools
- `uninstall_vscode.sh` - Visual Studio Code
- `uninstall_android_studio.sh` - Android Studio
- `uninstall_android_cmdline_tools.sh` - Android SDK Command-Line Tools
- `uninstall_git.sh` - Git version control

### Programming Languages
- `uninstall_python.sh` - Python and pip
- `uninstall_nodejs.sh` - Node.js and npm
- `uninstall_java.sh` - Java JDK
- `uninstall_rust.sh` - Rust and Cargo

### Databases
- `uninstall_mysql.sh` - MySQL Server
- `uninstall_postgresql.sh` - PostgreSQL
- `uninstall_mongodb.sh` - MongoDB
- `uninstall_redis.sh` - Redis
- `uninstall_sqlite.sh` - SQLite

### System Utilities
- `uninstall_snapd.sh` - Snap package manager
- `uninstall_blueman.sh` - Bluetooth manager
- `uninstall_gedit.sh` - Text editor
- `uninstall_freefilesync.sh` - File synchronization tool
- `uninstall_xarchiver.sh` - Archive manager
- `uninstall_teamviewer.sh` - Remote desktop software
- `uninstall_inotifytools.sh` - File system monitoring

### Network Tools
- `uninstall_smb.sh` - Samba file sharing
- `uninstall_filezilla.sh` - FTP client
- `uninstall_ftp.sh` - FTP server
- `uninstall_rsync.sh` - File synchronization
- `uninstall_ngrok.sh` - Secure tunneling
- `uninstall_discord.sh` - Communication platform

### System Monitoring & Configuration
- `uninstall_system_monitor.sh` - System monitoring tools
- `uninstall_hdd_mount.sh` - Automatic HDD mounting

### Other Applications
- `uninstall_qbittorrent.sh` - Torrent client
- `uninstall_jupyter.sh` - Jupyter Notebook
- `uninstall_gradle.sh` - Build automation tool

## Features

- **Interactive Confirmation**: Each script asks for confirmation before uninstalling
- **Data Preservation Options**: For database tools, options to backup data before removal
- **Configuration Cleanup**: Removes configuration files and directories
- **Dependency Handling**: Properly removes dependencies and performs cleanup

## Notes

- Some uninstallation scripts may require sudo privileges
- Always review the actions that will be performed before confirming
- For tools that store user data, you'll be given the option to preserve that data
- The uninstall scripts follow the same modular approach as the installation scripts