#!/bin/bash
set -e

# Make all metric scripts executable
chmod +x "$HOME/.local/bin/system-metrics"/*.sh 2>/dev/null || true

# ---- System Monitor for Top Bar ----
echo "📊 Installing System Monitor for Ubuntu Top Bar..."

# Install required packages
echo "📦 Installing required packages..."
sudo apt update
sudo apt install -y gnome-shell-extension-manager gnome-tweaks

# Install system monitor extension dependencies
sudo apt install -y gir1.2-gtop-2.0 gir1.2-nm-1.0 gir1.2-clutter-1.0

# Create system metrics scripts directory
METRICS_DIR="$HOME/.local/bin/system-metrics"
mkdir -p "$METRICS_DIR"

echo "📝 Creating system metrics scripts..."

# Create CPU usage script
cat > "$METRICS_DIR/cpu_usage.sh" << 'EOF'
#!/bin/bash
# Get CPU usage percentage
cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
printf "%.1f%%" "$cpu_usage"
EOF

# Create RAM usage script
cat > "$METRICS_DIR/ram_usage.sh" << 'EOF'
#!/bin/bash
# Get RAM usage
mem_info=$(free -m | awk 'NR==2{printf "%.1f%%", $3*100/$2}')
echo "$mem_info"
EOF

# Create disk usage script
cat > "$METRICS_DIR/disk_usage.sh" << 'EOF'
#!/bin/bash
# Get disk usage for root partition
disk_usage=$(df -h / | awk 'NR==2{print $5}')
echo "$disk_usage"
EOF

# Create network usage script
cat > "$METRICS_DIR/network_usage.sh" << 'EOF'
#!/bin/bash
# Get network interface with highest traffic
interface=$(ip route | grep default | awk '{print $5}' | head -1)
if [ -n "$interface" ]; then
    rx_bytes=$(cat /sys/class/net/$interface/statistics/rx_bytes 2>/dev/null || echo 0)
    tx_bytes=$(cat /sys/class/net/$interface/statistics/tx_bytes 2>/dev/null || echo 0)
    
    # Convert to MB
    rx_mb=$((rx_bytes / 1024 / 1024))
    tx_mb=$((tx_bytes / 1024 / 1024))
    
    echo "↓${rx_mb}MB ↑${tx_mb}MB"
else
    echo "No Network"
fi
EOF

# Create temperature script
cat > "$METRICS_DIR/temperature.sh" << 'EOF'
#!/bin/bash
# Get CPU temperature
if command -v sensors &> /dev/null; then
    temp=$(sensors | grep -E "Core 0|Package id 0" | head -1 | awk '{print $3}' | sed 's/+//g' | sed 's/°C//g')
    if [ -n "$temp" ]; then
        echo "${temp}°C"
    else
        echo "N/A"
    fi
else
    # Fallback to thermal zone
    if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
        temp=$(cat /sys/class/thermal/thermal_zone0/temp)
        temp_c=$((temp / 1000))
        echo "${temp_c}°C"
    else
        echo "N/A"
    fi
fi
EOF

# Create combined system info script
cat > "$METRICS_DIR/system_info.sh" << 'EOF'
#!/bin/bash
# Combined system information
cpu=$($HOME/.local/bin/system-metrics/cpu_usage.sh)
ram=$($HOME/.local/bin/system-metrics/ram_usage.sh)
disk=$($HOME/.local/bin/system-metrics/disk_usage.sh)
temp=$($HOME/.local/bin/system-metrics/temperature.sh)

echo "CPU:$cpu RAM:$ram DISK:$disk TEMP:$temp"
EOF

# Make all scripts executable
chmod +x "$METRICS_DIR"/*.sh

# Install lm-sensors for temperature monitoring
echo "🌡️ Installing temperature sensors..."
sudo apt install -y lm-sensors
sudo sensors-detect --auto

echo "🔧 Setting up GNOME extension..."

# Download and install System Monitor extension
EXTENSION_DIR="$HOME/.local/share/gnome-shell/extensions"
mkdir -p "$EXTENSION_DIR"

# Create a simple system monitor extension
EXTENSION_UUID="system-monitor@local"
EXTENSION_PATH="$EXTENSION_DIR/$EXTENSION_UUID"
mkdir -p "$EXTENSION_PATH"

# Create extension metadata
cat > "$EXTENSION_PATH/metadata.json" << EOF
{
  "uuid": "$EXTENSION_UUID",
  "name": "System Monitor",
  "description": "Display system metrics in top bar",
  "shell-version": ["42", "43", "44", "45"],
  "version": 1
}
EOF

# Create extension.js
cat > "$EXTENSION_PATH/extension.js" << 'EOF'
const { GObject, St, Clutter, GLib } = imports.gi;
const Main = imports.ui.main;
const PanelMenu = imports.ui.panelMenu;

let systemMonitor;

const SystemMonitor = GObject.registerClass(
class SystemMonitor extends PanelMenu.Button {
    _init() {
        super._init(0.0, 'System Monitor');
        
        this.label = new St.Label({
            text: 'Loading...',
            y_align: Clutter.ActorAlign.CENTER
        });
        
        this.add_child(this.label);
        
        this._updateMetrics();
        this._timeout = GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, 2, () => {
            this._updateMetrics();
            return GLib.SOURCE_CONTINUE;
        });
    }
    
    _updateMetrics() {
        try {
            let proc = GLib.spawn_command_line_sync('bash -c "$HOME/.local/bin/system-metrics/system_info.sh"');
            if (proc[0]) {
                let output = proc[1].toString().trim();
                this.label.set_text(output);
            }
        } catch (e) {
            this.label.set_text('Error loading metrics');
        }
    }
    
    destroy() {
        if (this._timeout) {
            GLib.source_remove(this._timeout);
            this._timeout = null;
        }
        super.destroy();
    }
});

function init() {
    return new SystemMonitor();
}

function enable() {
    systemMonitor = new SystemMonitor();
    Main.panel.addToStatusArea('system-monitor', systemMonitor);
}

function disable() {
    if (systemMonitor) {
        systemMonitor.destroy();
        systemMonitor = null;
    }
}
EOF

echo "✅ System Monitor scripts created successfully!"
echo ""
echo "📋 Available scripts:"
echo "  • CPU Usage: $METRICS_DIR/cpu_usage.sh"
echo "  • RAM Usage: $METRICS_DIR/ram_usage.sh"
echo "  • Disk Usage: $METRICS_DIR/disk_usage.sh"
echo "  • Network Usage: $METRICS_DIR/network_usage.sh"
echo "  • Temperature: $METRICS_DIR/temperature.sh"
echo "  • Combined Info: $METRICS_DIR/system_info.sh"
echo ""
echo "🔧 To enable the top bar extension:"
echo "  1. Log out and log back in (or restart GNOME Shell with Alt+F2, type 'r')"
echo "  2. Open Extensions app or use: gnome-extensions enable $EXTENSION_UUID"
echo ""
echo "📊 Alternative: Install 'System Monitor' extension from GNOME Extensions website"
echo "   Visit: https://extensions.gnome.org/extension/120/system-monitor/"