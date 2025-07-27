#!/bin/bash
# Network Monitor Script - Shows network usage and statistics

show_usage() {
    echo "Usage: $0 [OPTIONS] [INTERFACE]"
    echo "Options:"
    echo "  -c, --continuous    Show continuous monitoring"
    echo "  -i, --interval N    Update interval in seconds (default: 1)"
    echo "  -a, --all          Show all network interfaces"
    echo "  -s, --speed        Show connection speeds"
    echo "  -h, --help         Show this help"
    echo ""
    echo "Examples:"
    echo "  $0                 # Show default interface stats"
    echo "  $0 eth0            # Show specific interface stats"
    echo "  $0 -a              # Show all interfaces"
    echo "  $0 -c -s           # Continuous monitoring with speeds"
}

get_default_interface() {
    # Get the default route interface
    ip route | grep default | awk '{print $5}' | head -1
}

get_all_interfaces() {
    # Get all active network interfaces (excluding loopback)
    ip link show | grep -E "^[0-9]+:" | grep -v "lo:" | awk -F': ' '{print $2}' | cut -d'@' -f1
}

get_interface_stats() {
    local interface="$1"
    
    if [ ! -d "/sys/class/net/$interface" ]; then
        echo "ERROR|Interface $interface not found"
        return
    fi
    
    # Read statistics from /sys/class/net
    rx_bytes=$(cat "/sys/class/net/$interface/statistics/rx_bytes" 2>/dev/null || echo 0)
    tx_bytes=$(cat "/sys/class/net/$interface/statistics/tx_bytes" 2>/dev/null || echo 0)
    rx_packets=$(cat "/sys/class/net/$interface/statistics/rx_packets" 2>/dev/null || echo 0)
    tx_packets=$(cat "/sys/class/net/$interface/statistics/tx_packets" 2>/dev/null || echo 0)
    rx_errors=$(cat "/sys/class/net/$interface/statistics/rx_errors" 2>/dev/null || echo 0)
    tx_errors=$(cat "/sys/class/net/$interface/statistics/tx_errors" 2>/dev/null || echo 0)
    
    # Get interface status
    operstate=$(cat "/sys/class/net/$interface/operstate" 2>/dev/null || echo "unknown")
    
    # Get IP address
    ip_addr=$(ip addr show "$interface" 2>/dev/null | grep "inet " | awk '{print $2}' | cut -d'/' -f1 | head -1)
    [ -z "$ip_addr" ] && ip_addr="No IP"
    
    # Get link speed (if available)
    speed=$(cat "/sys/class/net/$interface/speed" 2>/dev/null || echo "unknown")
    [ "$speed" = "unknown" ] || speed="${speed}Mbps"
    
    echo "$interface|$rx_bytes|$tx_bytes|$rx_packets|$tx_packets|$rx_errors|$tx_errors|$operstate|$ip_addr|$speed"
}

format_bytes() {
    local bytes=$1
    
    if [ $bytes -gt 1073741824 ]; then
        awk "BEGIN {printf \"%.2fGB\", $bytes / 1073741824}"
    elif [ $bytes -gt 1048576 ]; then
        awk "BEGIN {printf \"%.2fMB\", $bytes / 1048576}"
    elif [ $bytes -gt 1024 ]; then
        awk "BEGIN {printf \"%.2fKB\", $bytes / 1024}"
    else
        echo "${bytes}B"
    fi
}

format_speed() {
    local bytes_per_sec=$1
    
    if [ $bytes_per_sec -gt 1048576 ]; then
        awk "BEGIN {printf \"%.2fMB/s\", $bytes_per_sec / 1048576}"
    elif [ $bytes_per_sec -gt 1024 ]; then
        awk "BEGIN {printf \"%.2fKB/s\", $bytes_per_sec / 1024}"
    else
        echo "${bytes_per_sec}B/s"
    fi
}

get_interface_info() {
    local interface="$1"
    local stats=$(get_interface_stats "$interface")
    
    IFS='|' read -r iface rx_bytes tx_bytes rx_packets tx_packets rx_errors tx_errors operstate ip_addr speed <<< "$stats"
    
    if [ "$iface" = "ERROR" ]; then
        echo "❌ $rx_bytes"
        return
    fi
    
    # Status indicator
    case "$operstate" in
        "up") status="🟢" ;;
        "down") status="🔴" ;;
        *) status="🟡" ;;
    esac
    
    echo "$status $interface ($operstate)"
    echo "  IP Address: $ip_addr"
    [ "$speed" != "unknown" ] && echo "  Link Speed: $speed"
    echo "  RX: $(format_bytes $rx_bytes) ($rx_packets packets, $rx_errors errors)"
    echo "  TX: $(format_bytes $tx_bytes) ($tx_packets packets, $tx_errors errors)"
}

display_single_interface() {
    local interface="$1"
    echo "🌐 Network Interface: $interface"
    echo "==============================="
    get_interface_info "$interface"
}

display_all_interfaces() {
    echo "🌐 Network Interfaces"
    echo "===================="
    
    get_all_interfaces | while read interface; do
        get_interface_info "$interface"
        echo ""
    done
}

display_continuous() {
    local interface="$1"
    echo "🌐 Network Monitor (Press Ctrl+C to stop)"
    echo "========================================="
    
    # Get initial values for rate calculation
    prev_stats=$(get_interface_stats "$interface")
    IFS='|' read -r prev_iface prev_rx prev_tx prev_rx_packets prev_tx_packets prev_rx_errors prev_tx_errors prev_operstate prev_ip prev_speed <<< "$prev_stats"
    
    sleep "$INTERVAL"
    
    while true; do
        current_stats=$(get_interface_stats "$interface")
        IFS='|' read -r iface rx_bytes tx_bytes rx_packets tx_packets rx_errors tx_errors operstate ip_addr speed <<< "$current_stats"
        
        if [ "$iface" = "ERROR" ]; then
            echo "❌ $rx_bytes"
            sleep "$INTERVAL"
            continue
        fi
        
        # Calculate rates
        rx_rate=$(( (rx_bytes - prev_rx) / INTERVAL ))
        tx_rate=$(( (tx_bytes - prev_tx) / INTERVAL ))
        rx_packet_rate=$(( (rx_packets - prev_rx_packets) / INTERVAL ))
        tx_packet_rate=$(( (tx_packets - prev_tx_packets) / INTERVAL ))
        
        timestamp=$(date '+%H:%M:%S')
        
        # Status indicator
        case "$operstate" in
            "up") status="🟢" ;;
            "down") status="🔴" ;;
            *) status="🟡" ;;
        esac
        
        if [ "$SHOW_ALL" = true ]; then
            clear
            echo "🌐 Network Monitor - All Interfaces ($(date '+%H:%M:%S'))"
            echo "======================================================"
            
            get_all_interfaces | while read iface_name; do
                iface_stats=$(get_interface_stats "$iface_name")
                IFS='|' read -r name rx tx rx_pkt tx_pkt rx_err tx_err state ip spd <<< "$iface_stats"
                
                case "$state" in
                    "up") st="🟢" ;;
                    "down") st="🔴" ;;
                    *) st="🟡" ;;
                esac
                
                printf "%s %-10s %s ↓%s ↑%s\n" "$st" "$name" "$ip" "$(format_bytes $rx)" "$(format_bytes $tx)"
            done
        else
            # Create visual bars for network activity
            max_rate=1048576  # 1MB/s for scale
            rx_bar_length=$(awk "BEGIN {printf \"%.0f\", ($rx_rate * 20) / $max_rate}")
            tx_bar_length=$(awk "BEGIN {printf \"%.0f\", ($tx_rate * 20) / $max_rate}")
            
            [ $rx_bar_length -gt 20 ] && rx_bar_length=20
            [ $tx_bar_length -gt 20 ] && tx_bar_length=20
            
            rx_bar=""
            tx_bar=""
            for ((i=0; i<rx_bar_length; i++)); do rx_bar+="█"; done
            for ((i=rx_bar_length; i<20; i++)); do rx_bar+="░"; done
            for ((i=0; i<tx_bar_length; i++)); do tx_bar+="█"; done
            for ((i=tx_bar_length; i<20; i++)); do tx_bar+="░"; done
            
            printf "\r%s %s %s ↓%s [%s] ↑%s [%s]" \
                "$timestamp" "$status" "$interface" \
                "$(format_speed $rx_rate)" "$rx_bar" \
                "$(format_speed $tx_rate)" "$tx_bar"
            
            if [ "$SHOW_SPEED" = true ]; then
                printf " | Packets: ↓%d/s ↑%d/s" "$rx_packet_rate" "$tx_packet_rate"
            fi
        fi
        
        # Update previous values
        prev_rx=$rx_bytes
        prev_tx=$tx_bytes
        prev_rx_packets=$rx_packets
        prev_tx_packets=$tx_packets
        
        sleep "$INTERVAL"
    done
}

# Parse command line arguments
CONTINUOUS=false
SHOW_ALL=false
SHOW_SPEED=false
INTERVAL=1
TARGET_INTERFACE=""

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
        -s|--speed)
            SHOW_SPEED=true
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
            TARGET_INTERFACE="$1"
            shift
            ;;
    esac
done

# Determine target interface
if [ -z "$TARGET_INTERFACE" ]; then
    TARGET_INTERFACE=$(get_default_interface)
    if [ -z "$TARGET_INTERFACE" ]; then
        echo "❌ No default network interface found"
        exit 1
    fi
fi

# Main execution
if [ "$CONTINUOUS" = true ]; then
    display_continuous "$TARGET_INTERFACE"
elif [ "$SHOW_ALL" = true ]; then
    display_all_interfaces
else
    display_single_interface "$TARGET_INTERFACE"
fi