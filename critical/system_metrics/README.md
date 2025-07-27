# System Metrics Scripts

This directory contains comprehensive system monitoring scripts for Ubuntu that can display system metrics in the top bar and provide detailed system information.

## 📊 Available Scripts

### 1. **CPU Monitor** (`cpu_monitor.sh`)
Monitors CPU usage with real-time updates and visual bars.

```bash
# Basic usage
./cpu_monitor.sh

# Continuous monitoring
./cpu_monitor.sh -c

# Continuous with custom interval
./cpu_monitor.sh -c -i 2
```

**Features:**
- Real-time CPU usage percentage
- Visual progress bars
- Continuous monitoring mode
- Customizable update intervals

### 2. **RAM Monitor** (`ram_monitor.sh`)
Displays memory usage including RAM and swap information.

```bash
# Basic usage
./ram_monitor.sh

# Detailed memory breakdown
./ram_monitor.sh -d

# Continuous monitoring
./ram_monitor.sh -c
```

**Features:**
- RAM usage (total, used, available)
- Swap usage information
- Visual memory bars
- Detailed breakdown mode

### 3. **Disk Monitor** (`disk_monitor.sh`)
Shows disk usage and I/O statistics for filesystems.

```bash
# Root filesystem usage
./disk_monitor.sh

# Specific path
./disk_monitor.sh /home

# All filesystems
./disk_monitor.sh -a

# Continuous with I/O stats
./disk_monitor.sh -c --show-io
```

**Features:**
- Disk usage for any path
- All mounted filesystems view
- Disk I/O statistics
- Color-coded usage warnings

### 4. **Network Monitor** (`network_monitor.sh`)
Monitors network interfaces and traffic statistics.

```bash
# Default interface
./network_monitor.sh

# Specific interface
./network_monitor.sh eth0

# All interfaces
./network_monitor.sh -a

# Continuous with speeds
./network_monitor.sh -c -s
```

**Features:**
- Network interface status
- Real-time traffic rates
- IP address information
- Multiple interface support

### 5. **Temperature Monitor** (`temperature_monitor.sh`)
Displays system temperature information from various sensors.

```bash
# CPU temperature
./temperature_monitor.sh

# All sensors
./temperature_monitor.sh -a

# Continuous monitoring
./temperature_monitor.sh -c

# Fahrenheit display
./temperature_monitor.sh -f

# With warnings
./temperature_monitor.sh -c -w
```

**Features:**
- CPU temperature monitoring
- All system sensors
- Temperature warnings
- Celsius/Fahrenheit support

### 6. **System Overview** (`system_overview.sh`)
Comprehensive system information dashboard.

```bash
# Full system overview
./system_overview.sh

# Simple format
./system_overview.sh -s

# JSON output
./system_overview.sh -j

# Continuous monitoring
./system_overview.sh -c
```

**Features:**
- Complete system information
- Multiple output formats
- JSON export capability
- Real-time dashboard

## 🔧 Installation

The system monitor scripts are automatically installed when you run:

```bash
bash scripts/install_system_monitor.sh
```

This will:
1. Install required packages (`gnome-shell-extension-manager`, `lm-sensors`, etc.)
2. Create all monitoring scripts in `~/.local/bin/system-metrics/`
3. Set up a GNOME Shell extension for top bar display
4. Configure temperature sensors

## 📱 Top Bar Integration

### Method 1: Custom GNOME Extension (Included)
The installation script creates a custom GNOME extension that displays system metrics in the top bar.

**To enable:**
1. Log out and log back in (or restart GNOME Shell: Alt+F2, type 'r')
2. Enable the extension: `gnome-extensions enable system-monitor@local`

### Method 2: System Monitor Extension (Recommended)
Install the popular "System Monitor" extension from GNOME Extensions:

1. Visit: https://extensions.gnome.org/extension/120/system-monitor/
2. Install the browser extension
3. Toggle ON the System Monitor extension
4. Configure which metrics to display

### Method 3: Manual Top Bar Scripts
Use the individual scripts in status bars or panels:

```bash
# For status bars like i3status, polybar, etc.
~/.local/bin/system-metrics/system_info.sh
```

## 🎨 Customization

### Custom Metrics Script
Create your own combined metrics display:

```bash
#!/bin/bash
# Custom system info
cpu=$(~/.local/bin/system-metrics/cpu_usage.sh)
ram=$(~/.local/bin/system-metrics/ram_usage.sh)
temp=$(~/.local/bin/system-metrics/temperature.sh)

echo "CPU:$cpu RAM:$ram TEMP:$temp"
```

### Update Intervals
Most scripts support custom update intervals:

```bash
# Update every 5 seconds
./cpu_monitor.sh -c -i 5
```

## 🔍 Troubleshooting

### Temperature Not Working
```bash
# Install and configure sensors
sudo apt install lm-sensors
sudo sensors-detect --auto
```

### Permission Issues
```bash
# Make scripts executable
chmod +x ~/.local/bin/system-metrics/*.sh
```

### GNOME Extension Not Loading
```bash
# Restart GNOME Shell
Alt+F2, type 'r', press Enter

# Or log out and back in
```

## 📋 Script Options Summary

| Script | Continuous | All/Detailed | Custom Interval | Special Options |
|--------|------------|--------------|-----------------|-----------------|
| `cpu_monitor.sh` | `-c` | - | `-i N` | - |
| `ram_monitor.sh` | `-c` | `-d` | `-i N` | - |
| `disk_monitor.sh` | `-c` | `-a` | `-i N` | `--show-io` |
| `network_monitor.sh` | `-c` | `-a` | `-i N` | `-s` (speeds) |
| `temperature_monitor.sh` | `-c` | `-a` | `-i N` | `-f` (Fahrenheit), `-w` (warnings) |
| `system_overview.sh` | `-c` | - | `-i N` | `-s` (simple), `-j` (JSON) |

## 🚀 Performance Impact

These scripts are designed to be lightweight:
- Use native system files (`/proc`, `/sys`) when possible
- Minimal external dependencies
- Efficient parsing and calculations
- Configurable update intervals to balance accuracy vs. performance

## 📝 Examples

### Dashboard in Terminal
```bash
# Real-time system dashboard
./system_overview.sh -c
```

### Export System Info
```bash
# JSON export for logging/monitoring
./system_overview.sh -j > system_info.json
```

### Monitor Specific Resources
```bash
# Monitor high CPU usage
./cpu_monitor.sh -c -i 1

# Watch memory during heavy tasks
./ram_monitor.sh -c -d

# Monitor disk I/O during file operations
./disk_monitor.sh -c --show-io
```

### Temperature Monitoring
```bash
# Monitor CPU temperature with warnings
./temperature_monitor.sh -c -w

# All sensors in Fahrenheit
./temperature_monitor.sh -a -f
```

These scripts provide a comprehensive system monitoring solution that can be integrated into Ubuntu's top bar or used standalone for system administration and monitoring tasks.