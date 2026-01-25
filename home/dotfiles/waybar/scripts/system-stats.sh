#!/usr/bin/env bash
# System Stats Monitor for Waybar
# Shows CPU, RAM, Temperature in a compact format

# Get CPU usage
get_cpu() {
    local cpu_usage
    cpu_usage=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {printf "%.0f", usage}')
    echo "$cpu_usage"
}

# Get RAM usage
get_ram() {
    local ram_usage
    ram_usage=$(free | awk '/Mem:/ {printf "%.0f", $3/$2 * 100}')
    echo "$ram_usage"
}

# Get CPU temperature (Intel)
get_temp() {
    local temp
    if [[ -f /sys/class/thermal/thermal_zone0/temp ]]; then
        temp=$(cat /sys/class/thermal/thermal_zone0/temp)
        temp=$((temp / 1000))
    else
        temp="--"
    fi
    echo "$temp"
}

# Main output
cpu=$(get_cpu)
ram=$(get_ram)
temp=$(get_temp)

# Determine class based on values
class="normal"
if [[ "$cpu" -gt 80 ]] || [[ "$ram" -gt 85 ]] || [[ "$temp" -gt 80 ]]; then
    class="warning"
fi
if [[ "$cpu" -gt 95 ]] || [[ "$ram" -gt 95 ]] || [[ "$temp" -gt 90 ]]; then
    class="critical"
fi

# Output for Waybar
echo "{\"text\": \" ${cpu}%  ${ram}%  ${temp}°\", \"tooltip\": \"CPU: ${cpu}%\\nRAM: ${ram}%\\nTemp: ${temp}°C\", \"class\": \"$class\"}"
