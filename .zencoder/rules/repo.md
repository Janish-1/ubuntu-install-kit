---
description: Repository Information Overview
alwaysApply: true
---

# Ubuntu Installation Kit Information

## Summary
This project provides a set of shell scripts to automate the installation of essential tools, programming languages, and databases on Ubuntu. The scripts check for the existence of each tool and install them if they are not already present. The repository also includes system monitoring scripts and utilities for critical system setup.

## Structure
- **scripts/**: Contains individual installation scripts for various tools and applications
- **critical/**: Contains scripts for critical system setup and monitoring
  - **system_metrics/**: Comprehensive system monitoring scripts for Ubuntu
- **install_tools.sh**: Main script that executes all individual installation scripts

## Language & Runtime
**Language**: Bash shell scripts
**Version**: Compatible with Bash 4.x+
**Dependencies**: Ubuntu/Debian-based Linux distribution

## Key Components

### Installation Scripts
**Main Script**: `install_tools.sh`
**Individual Scripts**:
- Programming Languages: Python, Node.js, Java, Gradle
- Databases: MySQL, PostgreSQL, MongoDB, Redis, SQLite
- Development Tools: Git, VS Code, Android Studio
- System Utilities: Snapd, Gedit, Blueman, FreeFileSync
- Other Applications: qBittorrent

**Installation Pattern**:
```bash
if ! command -v [tool] &> /dev/null; then
  # Installation commands
else
  echo "✅ [Tool] already installed."
fi
```

### System Monitoring
**Location**: `critical/system_metrics/`
**Main Scripts**:
- `cpu_monitor.sh`: Real-time CPU usage monitoring
- `ram_monitor.sh`: Memory usage monitoring
- `disk_monitor.sh`: Disk usage and I/O statistics
- `network_monitor.sh`: Network interface monitoring
- `temperature_monitor.sh`: System temperature monitoring
- `system_overview.sh`: Comprehensive system dashboard

**Features**:
- Real-time monitoring with visual indicators
- Continuous monitoring mode with customizable intervals
- Top bar integration via GNOME Shell extension
- Multiple output formats including JSON

### System Setup Utilities
**HDD Mount Setup**: `critical/setup_hdd_mount.sh`
- Configures automatic mounting of external drives
- Sets up proper permissions and mount points
- Adds entries to /etc/fstab for persistence

**System Monitor Installation**: `critical/install_system_monitor.sh`
- Installs required packages for system monitoring
- Creates monitoring scripts in ~/.local/bin/system-metrics/
- Sets up GNOME Shell extension for top bar display

## Usage & Operations
**Main Installation**:
```bash
chmod +x install_tools.sh
./install_tools.sh
```

**Individual Tool Installation**:
```bash
bash scripts/install_[tool].sh
```

**System Monitoring**:
```bash
# Basic usage
./critical/system_metrics/cpu_monitor.sh

# Continuous monitoring
./critical/system_metrics/cpu_monitor.sh -c

# With custom interval
./critical/system_metrics/cpu_monitor.sh -c -i 2
```

**System Setup**:
```bash
# Set up HDD mounting
bash critical/setup_hdd_mount.sh

# Install system monitoring
bash critical/install_system_monitor.sh
```

## Prerequisites
- Ubuntu/Debian-based Linux distribution
- Sudo privileges for package installation
- Internet connection for downloading packages