#!/bin/bash
# Disk Monitor Script - Shows disk usage and I/O statistics

show_usage() {
    echo "Usage: $0 [OPTIONS] [PATH]"
    echo "Options:"
    echo "  -c, --continuous    Show continuous monitoring"
    echo "  -i, --interval N    Update interval in seconds (default: 1)"
    echo "  -a, --all          Show all mounted filesystems"
    echo "  -io, --show-io     Show disk I/O statistics"
    echo "  -h, --help         Show this help"
    echo ""
    echo "Examples:"
    echo "  $0                 # Show root filesystem usage"
    echo "  $0 /home           # Show /home filesystem usage"
    echo "  $0 -a              # Show all filesystems"
    echo "  $0 -c --show-io    # Continuous monitoring with I/O stats"
}

get_disk_usage() {
    local path=${1:-"/"}
    
    # Get disk usage information
    df_output=$(df -h "$path" 2>/dev/null | tail -1)
    if [ $? -eq 0 ]; then
        filesystem=$(echo "$df_output" | awk '{print $1}')
        size=$(echo "$df_output" | awk '{print $2}')
        used=$(echo "$df_output" | awk '{print $3}')
        available=$(echo "$df_output" | awk '{print $4}')
        usage_percent=$(echo "$df_output" | awk '{print $5}' | sed 's/%//')
        mount_point=$(echo "$df_output" | awk '{print $6}')
        
        echo "$filesystem|$size|$used|$available|$usage_percent|$mount_point"
    else
        echo "ERROR|N/A|N/A|N/A|0|$path"
    fi
}

get_all_disk_usage() {
    # Get all mounted filesystems (excluding special filesystems)
    df -h -x tmpfs -x devtmpfs -x squashfs -x overlay | tail -n +2 | while read line; do
        filesystem=$(echo "$line" | awk '{print $1}')
        size=$(echo "$line" | awk '{print $2}')
        used=$(echo "$line" | awk '{print $3}')
        available=$(echo "$line" | awk '{print $4}')
        usage_percent=$(echo "$line" | awk '{print $5}' | sed 's/%//')
        mount_point=$(echo "$line" | awk '{print $6}')
        
        echo "$filesystem|$size|$used|$available|$usage_percent|$mount_point"
    done
}

get_disk_io() {
    # Get disk I/O statistics from /proc/diskstats
    if [ -f /proc/diskstats ]; then
        # Find the main disk device (usually sda, nvme0n1, etc.)
        main_disk=$(lsblk -no NAME,TYPE | grep disk | head -1 | awk '{print $1}')
        
        if [ -n "$main_disk" ]; then
            # Read current stats
            disk_stats=$(grep " $main_disk " /proc/diskstats)
            if [ -n "$disk_stats" ]; then
                read_sectors=$(echo "$disk_stats" | awk '{print $6}')
                write_sectors=$(echo "$disk_stats" | awk '{print $10}')
                
                # Convert sectors to MB (assuming 512 bytes per sector)
                read_mb=$((read_sectors * 512 / 1024 / 1024))
                write_mb=$((write_sectors * 512 / 1024 / 1024))
                
                echo "$main_disk|$read_mb|$write_mb"
            else
                echo "N/A|0|0"
            fi
        else
            echo "N/A|0|0"
        fi
    else
        echo "N/A|0|0"
    fi
}

format_disk_info() {
    local info="$1"
    IFS='|' read -r filesystem size used available usage_percent mount_point <<< "$info"
    
    if [ "$filesystem" = "ERROR" ]; then
        echo "❌ Error accessing $mount_point"
        return
    fi
    
    # Create visual bar
    bar_length=20
    filled_length=$(awk "BEGIN {printf \"%.0f\", $usage_percent * $bar_length / 100}")
    bar=""
    for ((i=0; i<filled_length; i++)); do bar+="█"; done
    for ((i=filled_length; i<bar_length; i++)); do bar+="░"; done
    
    # Color coding based on usage
    if [ $usage_percent -gt 90 ]; then
        color="🔴"
    elif [ $usage_percent -gt 80 ]; then
        color="🟡"
    else
        color="🟢"
    fi
    
    printf "%s %s: %s%% [%s] %s/%s (%s available)\n" \
        "$color" "$mount_point" "$usage_percent" "$bar" "$used" "$size" "$available"
}

display_single_disk() {
    local path=${1:-"/"}
    disk_info=$(get_disk_usage "$path")
    format_disk_info "$disk_info"
}

display_all_disks() {
    echo "💾 Disk Usage Information"
    echo "========================"
    
    get_all_disk_usage | while IFS='|' read -r filesystem size used available usage_percent mount_point; do
        info="$filesystem|$size|$used|$available|$usage_percent|$mount_point"
        format_disk_info "$info"
    done
}

display_continuous() {
    local path=${1:-"/"}
    echo "💾 Disk Monitor (Press Ctrl+C to stop)"
    echo "======================================"
    
    # Initialize previous I/O values for rate calculation
    if [ "$SHOW_IO" = true ]; then
        prev_io=$(get_disk_io)
        IFS='|' read -r prev_disk prev_read_mb prev_write_mb <<< "$prev_io"
        sleep 1
    fi
    
    while true; do
        if [ "$SHOW_ALL" = true ]; then
            clear
            echo "💾 Disk Monitor - All Filesystems ($(date '+%H:%M:%S'))"
            echo "=================================================="
            
            get_all_disk_usage | while IFS='|' read -r filesystem size used available usage_percent mount_point; do
                info="$filesystem|$size|$used|$available|$usage_percent|$mount_point"
                format_disk_info "$info"
            done
        else
            disk_info=$(get_disk_usage "$path")
            IFS='|' read -r filesystem size used available usage_percent mount_point <<< "$disk_info"
            
            timestamp=$(date '+%H:%M:%S')
            
            # Create visual bar
            bar_length=20
            filled_length=$(awk "BEGIN {printf \"%.0f\", $usage_percent * $bar_length / 100}")
            bar=""
            for ((i=0; i<filled_length; i++)); do bar+="█"; done
            for ((i=filled_length; i<bar_length; i++)); do bar+="░"; done
            
            printf "\r%s DISK: %s%% [%s] %s/%s" \
                "$timestamp" "$usage_percent" "$bar" "$used" "$size"
        fi
        
        # Show I/O statistics if requested
        if [ "$SHOW_IO" = true ]; then
            current_io=$(get_disk_io)
            IFS='|' read -r disk read_mb write_mb <<< "$current_io"
            
            if [ -n "$prev_read_mb" ] && [ -n "$prev_write_mb" ]; then
                read_rate=$((read_mb - prev_read_mb))
                write_rate=$((write_mb - prev_write_mb))
                
                if [ "$SHOW_ALL" != true ]; then
                    printf " | I/O: ↓%dMB/s ↑%dMB/s" "$read_rate" "$write_rate"
                else
                    echo ""
                    echo "📊 I/O Statistics ($disk): Read: ${read_rate}MB/s, Write: ${write_rate}MB/s"
                fi
            fi
            
            prev_read_mb=$read_mb
            prev_write_mb=$write_mb
        fi
        
        sleep "$INTERVAL"
    done
}

# Parse command line arguments
CONTINUOUS=false
SHOW_ALL=false
SHOW_IO=false
INTERVAL=1
TARGET_PATH="/"

while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--continuous)
            CONTINUOUS=true
            shift
            ;;
        -a|--all)
            SHOW_ALL=true
            shift
            ;;
        -io|--show-io)
            SHOW_IO=true
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
        -*)
            echo "Unknown option: $1"
            show_usage
            exit 1
            ;;
        *)
            TARGET_PATH="$1"
            shift
            ;;
    esac
done

# Main execution
if [ "$CONTINUOUS" = true ]; then
    display_continuous "$TARGET_PATH"
elif [ "$SHOW_ALL" = true ]; then
    display_all_disks
else
    display_single_disk "$TARGET_PATH"
fi