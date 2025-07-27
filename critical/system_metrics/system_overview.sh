#!/bin/bash
# System Overview Script - Shows comprehensive system information

show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -c, --continuous    Show continuous monitoring"
    echo "  -i, --interval N    Update interval in seconds (default: 2)"
    echo "  -s, --simple       Show simplified view"
    echo "  -j, --json         Output in JSON format"
    echo "  -h, --help         Show this help"
    echo ""
    echo "Examples:"
    echo "  $0                 # Show system overview"
    echo "  $0 -c              # Continuous monitoring"
    echo "  $0 -s              # Simplified view"
    echo "  $0 -j              # JSON output"
}

get_system_info() {
    # Basic system information
    hostname=$(hostname)
    kernel=$(uname -r)
    architecture=$(uname -m)
    uptime_info=$(uptime -p 2>/dev/null || uptime | awk -F'up ' '{print $2}' | awk -F',' '{print $1}')
    
    # OS information
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        os_name="$PRETTY_NAME"
    else
        os_name=$(uname -s)
    fi
    
    # Load average
    load_avg=$(uptime | awk -F'load average:' '{print $2}' | sed 's/^ *//')
    
    echo "SYSTEM|$hostname|$os_name|$kernel|$architecture|$uptime_info|$load_avg"
}

get_cpu_info() {
    # CPU information
    cpu_model=$(grep "model name" /proc/cpuinfo | head -1 | cut -d':' -f2 | sed 's/^ *//')
    cpu_cores=$(nproc)
    
    # CPU usage
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    
    # CPU frequency (if available)
    cpu_freq=""
    if [ -f /proc/cpuinfo ]; then
        cpu_freq=$(grep "cpu MHz" /proc/cpuinfo | head -1 | awk '{print $4}' | awk '{printf "%.0fMHz", $1}')
    fi
    
    echo "CPU|$cpu_model|$cpu_cores|$cpu_usage|$cpu_freq"
}

get_memory_info() {
    # Memory information from /proc/meminfo
    while IFS=: read -r key value; do
        case $key in
            MemTotal) mem_total=${value// kB/} ;;
            MemAvailable) mem_available=${value// kB/} ;;
            SwapTotal) swap_total=${value// kB/} ;;
            SwapFree) swap_free=${value// kB/} ;;
        esac
    done < /proc/meminfo
    
    # Convert to MB and calculate usage
    mem_total_mb=$((mem_total / 1024))
    mem_available_mb=$((mem_available / 1024))
    mem_used_mb=$((mem_total_mb - mem_available_mb))
    mem_usage_percent=$(awk "BEGIN {printf \"%.1f\", $mem_used_mb * 100 / $mem_total_mb}")
    
    # Swap information
    if [ $swap_total -gt 0 ]; then
        swap_total_mb=$((swap_total / 1024))
        swap_free_mb=$((swap_free / 1024))
        swap_used_mb=$((swap_total_mb - swap_free_mb))
        swap_usage_percent=$(awk "BEGIN {printf \"%.1f\", $swap_used_mb * 100 / $swap_total_mb}")
    else
        swap_total_mb=0
        swap_used_mb=0
        swap_usage_percent="0.0"
    fi
    
    echo "MEMORY|$mem_total_mb|$mem_used_mb|$mem_usage_percent|$swap_total_mb|$swap_used_mb|$swap_usage_percent"
}

get_disk_info() {
    # Root filesystem information
    disk_info=$(df -h / | tail -1)
    disk_total=$(echo "$disk_info" | awk '{print $2}')
    disk_used=$(echo "$disk_info" | awk '{print $3}')
    disk_available=$(echo "$disk_info" | awk '{print $4}')
    disk_usage_percent=$(echo "$disk_info" | awk '{print $5}' | sed 's/%//')
    
    echo "DISK|$disk_total|$disk_used|$disk_available|$disk_usage_percent"
}

get_network_info() {
    # Default network interface
    default_interface=$(ip route | grep default | awk '{print $5}' | head -1)
    
    if [ -n "$default_interface" ]; then
        # Get IP address
        ip_addr=$(ip addr show "$default_interface" 2>/dev/null | grep "inet " | awk '{print $2}' | cut -d'/' -f1 | head -1)
        
        # Get interface status
        operstate=$(cat "/sys/class/net/$default_interface/operstate" 2>/dev/null || echo "unknown")
        
        # Get network statistics
        rx_bytes=$(cat "/sys/class/net/$default_interface/statistics/rx_bytes" 2>/dev/null || echo 0)
        tx_bytes=$(cat "/sys/class/net/$default_interface/statistics/tx_bytes" 2>/dev/null || echo 0)
        
        # Convert to MB
        rx_mb=$((rx_bytes / 1024 / 1024))
        tx_mb=$((tx_bytes / 1024 / 1024))
        
        echo "NETWORK|$default_interface|$ip_addr|$operstate|$rx_mb|$tx_mb"
    else
        echo "NETWORK|none|No IP|down|0|0"
    fi
}

get_temperature_info() {
    # CPU temperature
    temp="0.0"
    
    # Try lm-sensors first
    if command -v sensors &> /dev/null; then
        temp=$(sensors 2>/dev/null | grep -E "(Core 0|Package id 0|Tctl)" | head -1 | grep -oE '\+[0-9]+\.[0-9]+°C' | sed 's/+//g' | sed 's/°C//g')
    fi
    
    # Fallback to thermal zones
    if [ -z "$temp" ] || [ "$temp" = "0.0" ]; then
        for thermal_zone in /sys/class/thermal/thermal_zone*/temp; do
            if [ -f "$thermal_zone" ]; then
                temp_raw=$(cat "$thermal_zone" 2>/dev/null)
                if [ -n "$temp_raw" ] && [ "$temp_raw" -gt 0 ]; then
                    temp=$(awk "BEGIN {printf \"%.1f\", $temp_raw / 1000}")
                    break
                fi
            fi
        done
    fi
    
    echo "TEMPERATURE|${temp:-0.0}"
}

get_process_info() {
    # Top processes by CPU and memory
    top_cpu=$(ps aux --sort=-%cpu | head -6 | tail -5 | awk '{printf "%s:%.1f ", $11, $3}')
    top_mem=$(ps aux --sort=-%mem | head -6 | tail -5 | awk '{printf "%s:%.1f ", $11, $4}')
    
    # Process count
    process_count=$(ps aux | wc -l)
    
    echo "PROCESSES|$process_count|$top_cpu|$top_mem"
}

format_json_output() {
    local system_info="$1"
    local cpu_info="$2"
    local memory_info="$3"
    local disk_info="$4"
    local network_info="$5"
    local temperature_info="$6"
    local process_info="$7"
    
    # Parse all information
    IFS='|' read -r _ hostname os_name kernel arch uptime load_avg <<< "$system_info"
    IFS='|' read -r _ cpu_model cpu_cores cpu_usage cpu_freq <<< "$cpu_info"
    IFS='|' read -r _ mem_total mem_used mem_percent swap_total swap_used swap_percent <<< "$memory_info"
    IFS='|' read -r _ disk_total disk_used disk_available disk_percent <<< "$disk_info"
    IFS='|' read -r _ net_interface ip_addr net_status rx_mb tx_mb <<< "$network_info"
    IFS='|' read -r _ temperature <<< "$temperature_info"
    IFS='|' read -r _ proc_count top_cpu top_mem <<< "$process_info"
    
    cat << EOF
{
  "timestamp": "$(date -Iseconds)",
  "system": {
    "hostname": "$hostname",
    "os": "$os_name",
    "kernel": "$kernel",
    "architecture": "$arch",
    "uptime": "$uptime",
    "load_average": "$load_avg"
  },
  "cpu": {
    "model": "$cpu_model",
    "cores": $cpu_cores,
    "usage_percent": $cpu_usage,
    "frequency": "$cpu_freq"
  },
  "memory": {
    "total_mb": $mem_total,
    "used_mb": $mem_used,
    "usage_percent": $mem_percent,
    "swap_total_mb": $swap_total,
    "swap_used_mb": $swap_used,
    "swap_usage_percent": $swap_percent
  },
  "disk": {
    "total": "$disk_total",
    "used": "$disk_used",
    "available": "$disk_available",
    "usage_percent": $disk_percent
  },
  "network": {
    "interface": "$net_interface",
    "ip_address": "$ip_addr",
    "status": "$net_status",
    "rx_mb": $rx_mb,
    "tx_mb": $tx_mb
  },
  "temperature": {
    "cpu_celsius": $temperature
  },
  "processes": {
    "total_count": $proc_count,
    "top_cpu": "$top_cpu",
    "top_memory": "$top_mem"
  }
}
EOF
}

display_overview() {
    local format="$1"
    
    # Collect all system information
    system_info=$(get_system_info)
    cpu_info=$(get_cpu_info)
    memory_info=$(get_memory_info)
    disk_info=$(get_disk_info)
    network_info=$(get_network_info)
    temperature_info=$(get_temperature_info)
    process_info=$(get_process_info)
    
    if [ "$format" = "json" ]; then
        format_json_output "$system_info" "$cpu_info" "$memory_info" "$disk_info" "$network_info" "$temperature_info" "$process_info"
        return
    fi
    
    # Parse information for display
    IFS='|' read -r _ hostname os_name kernel arch uptime load_avg <<< "$system_info"
    IFS='|' read -r _ cpu_model cpu_cores cpu_usage cpu_freq <<< "$cpu_info"
    IFS='|' read -r _ mem_total mem_used mem_percent swap_total swap_used swap_percent <<< "$memory_info"
    IFS='|' read -r _ disk_total disk_used disk_available disk_percent <<< "$disk_info"
    IFS='|' read -r _ net_interface ip_addr net_status rx_mb tx_mb <<< "$network_info"
    IFS='|' read -r _ temperature <<< "$temperature_info"
    
    if [ "$format" = "simple" ]; then
        # Simple format
        echo "🖥️  $hostname | 🐧 $os_name"
        echo "⏱️  Uptime: $uptime | 📊 Load: $load_avg"
        echo "🔧 CPU: ${cpu_usage}% | 🧠 RAM: ${mem_percent}% | 💾 Disk: ${disk_percent}%"
        echo "🌡️  Temp: ${temperature}°C | 🌐 IP: $ip_addr"
    else
        # Detailed format
        echo "╭─────────────────────────────────────────────────────────────╮"
        echo "│                    🖥️  SYSTEM OVERVIEW                      │"
        echo "├─────────────────────────────────────────────────────────────┤"
        echo "│ 🏠 Hostname: $hostname"
        echo "│ 🐧 OS: $os_name"
        echo "│ 🔧 Kernel: $kernel ($arch)"
        echo "│ ⏱️  Uptime: $uptime"
        echo "│ 📊 Load Average: $load_avg"
        echo "├─────────────────────────────────────────────────────────────┤"
        echo "│ 🔧 CPU: $cpu_model"
        echo "│    Cores: $cpu_cores | Usage: ${cpu_usage}% | Freq: $cpu_freq"
        echo "├─────────────────────────────────────────────────────────────┤"
        echo "│ 🧠 Memory: ${mem_used}MB/${mem_total}MB (${mem_percent}%)"
        if [ $swap_total -gt 0 ]; then
            echo "│ 💿 Swap: ${swap_used}MB/${swap_total}MB (${swap_percent}%)"
        fi
        echo "├─────────────────────────────────────────────────────────────┤"
        echo "│ 💾 Disk (/): ${disk_used}/${disk_total} (${disk_percent}%)"
        echo "│    Available: $disk_available"
        echo "├─────────────────────────────────────────────────────────────┤"
        echo "│ 🌐 Network: $net_interface ($net_status)"
        echo "│    IP: $ip_addr | RX: ${rx_mb}MB | TX: ${tx_mb}MB"
        echo "├─────────────────────────────────────────────────────────────┤"
        echo "│ 🌡️  Temperature: ${temperature}°C"
        echo "╰─────────────────────────────────────────────────────────────╯"
    fi
}

display_continuous() {
    local format="$1"
    
    if [ "$format" = "json" ]; then
        echo "❌ JSON format not supported in continuous mode"
        exit 1
    fi
    
    echo "🖥️  System Monitor (Press Ctrl+C to stop)"
    echo "========================================"
    
    while true; do
        if [ "$format" = "simple" ]; then
            printf "\r$(date '+%H:%M:%S') | "
            display_overview "simple" | tr '\n' ' '
        else
            clear
            echo "🖥️  System Monitor - $(date '+%Y-%m-%d %H:%M:%S')"
            echo "=============================================="
            display_overview "detailed"
        fi
        
        sleep "$INTERVAL"
    done
}

# Parse command line arguments
CONTINUOUS=false
FORMAT="detailed"
INTERVAL=2

while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--continuous)
            CONTINUOUS=true
            shift
            ;;
        -s|--simple)
            FORMAT="simple"
            shift
            ;;
        -j|--json)
            FORMAT="json"
            shift
            ;;
        -i|--interval)
            INTERVAL="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Main execution
if [ "$CONTINUOUS" = true ]; then
    display_continuous "$FORMAT"
else
    display_overview "$FORMAT"
fi