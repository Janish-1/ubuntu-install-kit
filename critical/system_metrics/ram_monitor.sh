#!/bin/bash
# RAM Monitor Script - Shows memory usage details

show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -c, --continuous    Show continuous monitoring"
    echo "  -i, --interval N    Update interval in seconds (default: 1)"
    echo "  -d, --detailed      Show detailed memory breakdown"
    echo "  -h, --help         Show this help"
    echo ""
    echo "Examples:"
    echo "  $0                 # Show current RAM usage"
    echo "  $0 -d              # Show detailed memory info"
    echo "  $0 -c              # Continuous monitoring"
}

get_memory_info() {
    # Read memory information from /proc/meminfo
    while IFS=: read -r key value; do
        case $key in
            MemTotal) mem_total=${value// kB/} ;;
            MemFree) mem_free=${value// kB/} ;;
            MemAvailable) mem_available=${value// kB/} ;;
            Buffers) buffers=${value// kB/} ;;
            Cached) cached=${value// kB/} ;;
            SwapTotal) swap_total=${value// kB/} ;;
            SwapFree) swap_free=${value// kB/} ;;
        esac
    done < /proc/meminfo
    
    # Convert KB to MB
    mem_total_mb=$((mem_total / 1024))
    mem_free_mb=$((mem_free / 1024))
    mem_available_mb=$((mem_available / 1024))
    buffers_mb=$((buffers / 1024))
    cached_mb=$((cached / 1024))
    
    # Calculate used memory
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
}

format_size() {
    local size_mb=$1
    if [ $size_mb -gt 1024 ]; then
        awk "BEGIN {printf \"%.1fGB\", $size_mb / 1024}"
    else
        echo "${size_mb}MB"
    fi
}

display_memory_info() {
    get_memory_info
    
    if [ "$DETAILED" = true ]; then
        echo "🧠 Memory Information"
        echo "===================="
        echo "Total RAM:     $(format_size $mem_total_mb)"
        echo "Used RAM:      $(format_size $mem_used_mb) (${mem_usage_percent}%)"
        echo "Available RAM: $(format_size $mem_available_mb)"
        echo "Free RAM:      $(format_size $mem_free_mb)"
        echo "Buffers:       $(format_size $buffers_mb)"
        echo "Cached:        $(format_size $cached_mb)"
        
        if [ $swap_total_mb -gt 0 ]; then
            echo ""
            echo "💾 Swap Information"
            echo "=================="
            echo "Total Swap:    $(format_size $swap_total_mb)"
            echo "Used Swap:     $(format_size $swap_used_mb) (${swap_usage_percent}%)"
            echo "Free Swap:     $(format_size $swap_free_mb)"
        fi
    else
        echo "RAM: ${mem_usage_percent}% ($(format_size $mem_used_mb)/$(format_size $mem_total_mb))"
    fi
}

display_continuous() {
    echo "🧠 RAM Monitor (Press Ctrl+C to stop)"
    echo "===================================="
    
    while true; do
        get_memory_info
        timestamp=$(date '+%H:%M:%S')
        
        # Create visual bar for RAM
        bar_length=20
        filled_length=$(awk "BEGIN {printf \"%.0f\", $mem_usage_percent * $bar_length / 100}")
        ram_bar=""
        for ((i=0; i<filled_length; i++)); do ram_bar+="█"; done
        for ((i=filled_length; i<bar_length; i++)); do ram_bar+="░"; done
        
        printf "\r%s RAM: %5.1f%% [%s] %s/%s" \
            "$timestamp" "$mem_usage_percent" "$ram_bar" \
            "$(format_size $mem_used_mb)" "$(format_size $mem_total_mb)"
        
        # Show swap if available
        if [ $swap_total_mb -gt 0 ] && [ $swap_used_mb -gt 0 ]; then
            swap_filled_length=$(awk "BEGIN {printf \"%.0f\", $swap_usage_percent * $bar_length / 100}")
            swap_bar=""
            for ((i=0; i<swap_filled_length; i++)); do swap_bar+="█"; done
            for ((i=swap_filled_length; i<bar_length; i++)); do swap_bar+="░"; done
            
            printf " | SWAP: %5.1f%% [%s]" "$swap_usage_percent" "$swap_bar"
        fi
        
        sleep "$INTERVAL"
    done
}

# Parse command line arguments
CONTINUOUS=false
DETAILED=false
INTERVAL=1

while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--continuous)
            CONTINUOUS=true
            shift
            ;;
        -d|--detailed)
            DETAILED=true
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
    display_continuous
else
    display_memory_info
fi