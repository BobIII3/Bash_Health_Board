#!/usr/bin/env bash

# ---------------- FUNCTION ----------------

get_date () {
    $(date) 
}

get_time () {
    $(uptime -p | sed 's/up //')  
}
    
get_cpu_usage () {
    
    CHARGE_1MIN=$(uptime | awk -F'load average:' '{ print $2 }' | cut -d',' -f1)
    NB_COEURS=$(nproc)

    UTILISATION=$(echo "scale=3; ($CHARGE_1MIN / $NB_COEURS) * 100" | bc)
}

get_ram () {
    (free -h | grep Mem | awk '{print $3 " / " $2}')
}

get_temp () {
    
    (cat /sys/class/thermal/thermal_zone*/temp | awk '{sum += $1; n++} END {if (n > 0) printf "%.1f", (sum / n)/1000 ; }' )
}

get_batterie () {

    ( upower -i $( upower -e | grep BAT) | grep percentage | awk '{ print $2 }' )
}

get_disque () {

    (df -h | grep /dev/nvme0n1p7 | awk '{printf "%.1f", ($3 / $2)*100 }')
}

# ---------------- DISPLAY  ----------------    
 
echo "            ***********************************                "
echo "            *                                 *                "
echo "            *           Dash Board            *                "
echo "            *                                 *                "
echo "            ***********************************                "

echo "    Date : $(get_date) " 
echo "    Uptime : $(get_time) "
echo "    Utilisation globale :$(get_cpu_usage) %"
echo "    RAM : $(get_ram)"
echo "    La température est : $(get_temp) °C"
echo "    Batterie : $(get_batterie) "
echo "    Memoire : $(get_disque) % utilise"

