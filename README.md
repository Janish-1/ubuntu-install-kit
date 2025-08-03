# Ubuntu Installation Kit

This project provides a set of scripts to automate the installation of essential tools on Ubuntu. The scripts check for the existence of each tool and install them if they are not already present.

## Project Structure

```
ubuntu-install-kit
├── scripts
│   ├── install_snapd.sh                # Installs snapd if missing
│   ├── install_gedit.sh                # Installs gedit if missing
│   ├── install_blueman.sh              # Installs blueman if missing
│   ├── install_vscode.sh               # Installs Visual Studio Code via Snap if missing
│   ├── install_android_studio.sh       # Installs Android Studio via Snap if missing
│   ├── install_android_cmdline_tools.sh # Installs Android SDK Command-Line Tools directly
│   ├── setup_android_sdk_path.sh       # Sets up Android SDK tools in PATH
│   ├── install_freefilesync.sh         # Downloads and installs FreeFileSync if missing
│   └── create_freefilesync_shortcut.sh # Creates a desktop shortcut for FreeFileSync
├── critical
│   ├── install_system_monitor.sh       # Installs system monitoring tools
│   ├── setup_hdd_mount.sh              # Sets up automatic HDD mounting
│   └── system_metrics                  # System monitoring scripts
├── install_tools.sh                    # Main script to run all installation scripts
└── README.md                           # Documentation for the project
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

## Android SDK Command-Line Tools

The repository includes scripts to set up Android SDK Command-Line Tools for global use:

### Option 1: Install Android Studio and SDK Tools

1. Run the main installation script which includes Android Studio installation:
   ```bash
   ./install_tools.sh
   ```

2. When Android Studio launches for the first time, make sure to install:
   - Android SDK Command-Line Tools (latest)
   - Android SDK Platform-Tools
   - Android Emulator
   - Android SDK Build-Tools

3. The setup script will automatically configure your PATH to include these tools.

### Option 2: Install SDK Command-Line Tools Directly (without Android Studio)

If you don't need the full Android Studio IDE, you can install just the command-line tools:

```bash
chmod +x scripts/install_android_cmdline_tools.sh
./scripts/install_android_cmdline_tools.sh
```

This will:
1. Download the latest Android SDK Command-Line Tools
2. Install essential components (platform-tools, emulator, build-tools)
3. Configure your PATH to include all the tools

### Available Android SDK Tools

After installation, the following tools will be available from any terminal:

- `sdkmanager` - Install/update SDK components
- `avdmanager` - Create/manage Android Virtual Devices
- `adb` - Android Debug Bridge for device communication
- `emulator` - Run Android emulators
- Various build tools (aapt, dx, etc.)

## Notes

- Each script is designed to check if the respective tool is already installed before attempting to install it.
- If you encounter any issues, please check the output messages for guidance on what might have gone wrong.
- For Android SDK tools, you may need to restart your terminal or run `source ~/.bashrc` for the PATH changes to take effect.