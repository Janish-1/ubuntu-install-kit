#!/bin/bash
# CPU Monitor Script - Shows real-time CPU usage

show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -c, --continuous    Show continuous monitoring"
    echo "  -i, --interval N    Update interval in seconds (default: 1)"
    echo "  -h, --help         Show this help"
    echo ""
    echo "Examples:"
    echo "  $0                 # Show current CPU usage"
    echo "  $0 -c              # Continuous monitoring"
    echo "  $0 -c -i 2         # Continuous with 2-second interval"
}

get_cpu_usage() {
    # Method 1: Using /proc/stat (more accurate)
    if [ -f /proc/stat ]; then
        cpu_line=$(head -1 /proc/stat)
        cpu_times=($cpu_line)
        
        idle=${cpu_times[4]}
        total=0
        for time in "${cpu_times[@]:1}"; do
            total=$((total + time))
        done
        
        if [ -n "$prev_idle" ] && [ -n "$prev_total" ]; then
            idle_diff=$((idle - prev_idle))
            total_diff=$((total - prev_total))
            
            if [ $total_diff -gt 0 ]; then
                cpu_usage=$(awk "BEGIN {printf \"%.1f\", 100 * (1 - $idle_diff / $total_diff)}")
            else
                cpu_usage="0.0"
            fi
        else
            cpu_usage="0.0"
        fi
        
        prev_idle=$idle
        prev_total=$total
    else
        # Fallback method using top
        cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    fi
    
    echo "$cpu_usage"
}

# Parse command line arguments
CONTINUOUS=false
INTERVAL=1

while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--continuous)
            CONTINUOUS=true
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
    echo "🖥️  CPU Monitor (Press Ctrl+C to stop)"
    echo "=================================="
    
    while true; do
        cpu_usage=$(get_cpu_usage)
        timestamp=$(date '+%H:%M:%S')
        
        # Create visual bar
        bar_length=20
        filled_length=$(awk "BEGIN {printf \"%.0f\", $cpu_usage * $bar_length / 100}")
        bar=""
        for ((i=0; i<filled_length; i++)); do bar+="█"; done
        for ((i=filled_length; i<bar_length; i++)); do bar+="░"; done
        
        printf "\r%s CPU: %5.1f%% [%s]" "$timestamp" "$cpu_usage" "$bar"
        
        sleep "$INTERVAL"
    done
else
    # Single measurement
    cpu_usage=$(get_cpu_usage)
    echo "CPU Usage: ${cpu_usage}%"
fi