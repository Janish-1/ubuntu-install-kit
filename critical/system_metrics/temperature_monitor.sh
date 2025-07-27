#!/bin/bash
# Temperature Monitor Script - Shows system temperature information

show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -c, --continuous    Show continuous monitoring"
    echo "  -i, --interval N    Update interval in seconds (default: 2)"
    echo "  -a, --all          Show all temperature sensors"
    echo "  -f, --fahrenheit   Show temperatures in Fahrenheit"
    echo "  -w, --warnings     Show temperature warnings"
    echo "  -h, --help         Show this help"
    echo ""
    echo "Examples:"
    echo "  $0                 # Show CPU temperature"
    echo "  $0 -a              # Show all sensors"
    echo "  $0 -c -w           # Continuous monitoring with warnings"
    echo "  $0 -f              # Show in Fahrenheit"
}

celsius_to_fahrenheit() {
    local celsius=$1
    awk "BEGIN {printf \"%.1f\", ($celsius * 9/5) + 32}"
}

get_cpu_temperature() {
    local temp=""
    
    # Method 1: Try lm-sensors
    if command -v sensors &> /dev/null; then
        # Try different sensor patterns
        temp=$(sensors 2>/dev/null | grep -E "(Core 0|Package id 0|Tctl|CPU)" | head -1 | grep -oE '\+[0-9]+\.[0-9]+°C' | sed 's/+//g' | sed 's/°C//g')
        
        # If no specific core found, try any temperature reading
        if [ -z "$temp" ]; then
            temp=$(sensors 2>/dev/null | grep -oE '\+[0-9]+\.[0-9]+°C' | head -1 | sed 's/+//g' | sed 's/°C//g')
        fi
    fi
    
    # Method 2: Try thermal zones
    if [ -z "$temp" ]; then
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
    
    # Method 3: Try ACPI
    if [ -z "$temp" ] && command -v acpi &> /dev/null; then
        temp=$(acpi -t 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
    fi
    
    echo "${temp:-0.0}"
}

get_all_temperatures() {
    declare -A temps
    
    # Get temperatures from lm-sensors
    if command -v sensors &> /dev/null; then
        while IFS= read -r line; do
            if [[ $line =~ ^[[:space:]]*([^:]+):[[:space:]]*\+([0-9]+\.[0-9]+)°C ]]; then
                sensor_name="${BASH_REMATCH[1]}"
                temp_value="${BASH_REMATCH[2]}"
                temps["$sensor_name"]="$temp_value"
            fi
        done < <(sensors 2>/dev/null)
    fi
    
    # Get temperatures from thermal zones
    for thermal_zone in /sys/class/thermal/thermal_zone*/temp; do
        if [ -f "$thermal_zone" ]; then
            zone_name=$(basename "$(dirname "$thermal_zone")")
            temp_raw=$(cat "$thermal_zone" 2>/dev/null)
            if [ -n "$temp_raw" ] && [ "$temp_raw" -gt 0 ]; then
                temp_celsius=$(awk "BEGIN {printf \"%.1f\", $temp_raw / 1000}")
                
                # Try to get a more descriptive name
                type_file="$(dirname "$thermal_zone")/type"
                if [ -f "$type_file" ]; then
                    zone_type=$(cat "$type_file" 2>/dev/null)
                    [ -n "$zone_type" ] && zone_name="$zone_type"
                fi
                
                temps["$zone_name"]="$temp_celsius"
            fi
        fi
    done
    
    # Output all temperatures
    for sensor in "${!temps[@]}"; do
        echo "$sensor|${temps[$sensor]}"
    done
}

get_temperature_status() {
    local temp=$1
    local temp_int=$(awk "BEGIN {printf \"%.0f\", $temp}")
    
    if [ $temp_int -ge 85 ]; then
        echo "🔥 CRITICAL"
    elif [ $temp_int -ge 75 ]; then
        echo "🟠 HOT"
    elif [ $temp_int -ge 65 ]; then
        echo "🟡 WARM"
    elif [ $temp_int -ge 45 ]; then
        echo "🟢 NORMAL"
    else
        echo "🔵 COOL"
    fi
}

format_temperature() {
    local temp=$1
    local unit=${2:-"C"}
    
    if [ "$unit" = "F" ]; then
        temp=$(celsius_to_fahrenheit "$temp")
        echo "${temp}°F"
    else
        echo "${temp}°C"
    fi
}

display_cpu_temperature() {
    local temp=$(get_cpu_temperature)
    local unit=${1:-"C"}
    
    if [ "$temp" = "0.0" ]; then
        echo "❌ Unable to read CPU temperature"
        echo "💡 Try installing lm-sensors: sudo apt install lm-sensors"
        echo "💡 Then run: sudo sensors-detect --auto"
        return
    fi
    
    local formatted_temp=$(format_temperature "$temp" "$unit")
    local status=$(get_temperature_status "$temp")
    
    echo "🌡️  CPU Temperature: $formatted_temp $status"
    
    if [ "$SHOW_WARNINGS" = true ]; then
        local temp_int=$(awk "BEGIN {printf \"%.0f\", $temp}")
        if [ $temp_int -ge 85 ]; then
            echo "⚠️  WARNING: CPU temperature is critically high!"
            echo "   Consider checking cooling system and cleaning fans"
        elif [ $temp_int -ge 75 ]; then
            echo "⚠️  CAUTION: CPU temperature is high"
            echo "   Monitor system performance and cooling"
        fi
    fi
}

display_all_temperatures() {
    local unit=${1:-"C"}
    
    echo "🌡️  System Temperature Sensors"
    echo "=============================="
    
    local sensor_count=0
    
    get_all_temperatures | while IFS='|' read -r sensor temp; do
        if [ -n "$sensor" ] && [ -n "$temp" ]; then
            formatted_temp=$(format_temperature "$temp" "$unit")
            status=$(get_temperature_status "$temp")
            
            printf "%-20s %s %s\n" "$sensor:" "$formatted_temp" "$status"
            sensor_count=$((sensor_count + 1))
        fi
    done
    
    if [ $sensor_count -eq 0 ]; then
        echo "❌ No temperature sensors found"
        echo "💡 Try installing lm-sensors: sudo apt install lm-sensors"
        echo "💡 Then run: sudo sensors-detect --auto"
    fi
}

display_continuous() {
    local unit=${1:-"C"}
    echo "🌡️  Temperature Monitor (Press Ctrl+C to stop)"
    echo "=============================================="
    
    while true; do
        if [ "$SHOW_ALL" = true ]; then
            clear
            echo "🌡️  Temperature Monitor - All Sensors ($(date '+%H:%M:%S'))"
            echo "========================================================="
            
            get_all_temperatures | while IFS='|' read -r sensor temp; do
                if [ -n "$sensor" ] && [ -n "$temp" ]; then
                    formatted_temp=$(format_temperature "$temp" "$unit")
                    status=$(get_temperature_status "$temp")
                    
                    # Create temperature bar
                    temp_int=$(awk "BEGIN {printf \"%.0f\", $temp}")
                    bar_length=20
                    max_temp=100
                    filled_length=$(awk "BEGIN {printf \"%.0f\", ($temp_int * $bar_length) / $max_temp}")
                    [ $filled_length -gt $bar_length ] && filled_length=$bar_length
                    
                    bar=""
                    for ((i=0; i<filled_length; i++)); do
                        if [ $i -lt 10 ]; then
                            bar+="█"  # Cool colors
                        elif [ $i -lt 15 ]; then
                            bar+="█"  # Warm colors
                        else
                            bar+="█"  # Hot colors
                        fi
                    done
                    for ((i=filled_length; i<bar_length; i++)); do bar+="░"; done
                    
                    printf "%-20s %s [%s] %s\n" "$sensor:" "$formatted_temp" "$bar" "$status"
                fi
            done
        else
            temp=$(get_cpu_temperature)
            if [ "$temp" != "0.0" ]; then
                timestamp=$(date '+%H:%M:%S')
                formatted_temp=$(format_temperature "$temp" "$unit")
                status=$(get_temperature_status "$temp")
                
                # Create temperature bar
                temp_int=$(awk "BEGIN {printf \"%.0f\", $temp}")
                bar_length=20
                max_temp=100
                filled_length=$(awk "BEGIN {printf \"%.0f\", ($temp_int * $bar_length) / $max_temp}")
                [ $filled_length -gt $bar_length ] && filled_length=$bar_length
                
                bar=""
                for ((i=0; i<filled_length; i++)); do bar+="█"; done
                for ((i=filled_length; i<bar_length; i++)); do bar+="░"; done
                
                printf "\r%s CPU: %s [%s] %s" \
                    "$timestamp" "$formatted_temp" "$bar" "$status"
                
                if [ "$SHOW_WARNINGS" = true ] && [ $temp_int -ge 75 ]; then
                    printf " ⚠️ "
                fi
            else
                printf "\r%s CPU: Temperature unavailable" "$(date '+%H:%M:%S')"
            fi
        fi
        
        sleep "$INTERVAL"
    done
}

# Parse command line arguments
CONTINUOUS=false
SHOW_ALL=false
USE_FAHRENHEIT=false
SHOW_WARNINGS=false
INTERVAL=2

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
        -f|--fahrenheit)
            USE_FAHRENHEIT=true
            shift
            ;;
        -w|--warnings)
            SHOW_WARNINGS=true
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

# Determine temperature unit
TEMP_UNIT="C"
[ "$USE_FAHRENHEIT" = true ] && TEMP_UNIT="F"

# Main execution
if [ "$CONTINUOUS" = true ]; then
    display_continuous "$TEMP_UNIT"
elif [ "$SHOW_ALL" = true ]; then
    display_all_temperatures "$TEMP_UNIT"
else
    display_cpu_temperature "$TEMP_UNIT"
fi