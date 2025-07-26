# Ubuntu Installation Kit

This project provides a set of scripts to automate the installation of essential tools on Ubuntu. The scripts check for the existence of each tool and install them if they are not already present.

## Project Structure

```
ubuntu-install-kit
├── scripts
│   ├── install_snapd.sh        # Installs snapd if missing
│   ├── install_gedit.sh        # Installs gedit if missing
│   ├── install_blueman.sh      # Installs blueman if missing
│   ├── install_vscode.sh       # Installs Visual Studio Code via Snap if missing
│   ├── install_freefilesync.sh  # Downloads and installs FreeFileSync if missing
│   └── create_freefilesync_shortcut.sh  # Creates a desktop shortcut for FreeFileSync
├── install_tools.sh            # Main script to run all installation scripts
└── README.md                   # Documentation for the project
```

## Prerequisites

- You need to have `sudo` privileges to install packages.
- Ensure that your system is connected to the internet to download the necessary packages.

## Usage

1. Open a terminal.
2. Navigate to the project directory:
   ```bash
   cd /path/to/ubuntu-install-kit
   ```
3. Make the main installation script executable:
   ```bash
   chmod +x install_tools.sh
   ```
4. Run the installation script:
   ```bash
   ./install_tools.sh
   ```

This will execute all the individual installation scripts in sequence, ensuring that all tools are installed and up-to-date.

## Notes

- Each script is designed to check if the respective tool is already installed before attempting to install it.
- If you encounter any issues, please check the output messages for guidance on what might have gone wrong.