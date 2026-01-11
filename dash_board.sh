#!/usr/bin/env bash

# ---------------- VARIABLE ----------------

GREEN='\033[0;32m'
ORANGE='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

# ---------------- FUNCTION ----------------

get_date () {
    (date) 
}

get_time () {
    (uptime -p | sed 's/up //')  
}
    
get_cpu_usage () {
    
    CHARGE_1MIN=$(uptime | awk -F'load average:' '{ print $2 }' | cut -d',' -f1)
    NB_COEURS=$(nproc)

    echo "scale=3; ($CHARGE_1MIN / $NB_COEURS) * 100" | bc

   
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

colorize () {

    local val=$1
    local orange=$2
    local red=$3
    local suffix=$4

    local int_val=${val%[.,]*}

    if [ "$int_val" -ge "$red" ]; then
        echo -e "${RED}${val}${suffix}${NC}"
    elif  [ "$int_val" -ge "$orange" ]; then
        echo -e "${ORANGE}${val}${suffix}${NC}"
    else
        echo -e "${GREEN}${val}${suffix}${NC}"
    fi
}

# ---------------- DISPLAY  ----------------    
 while true; do
    clear
                
    cat << "EOF" | python3 -c "import sys; w=$(tput cols); [print(line.rstrip().center(w)) for line in sys.stdin]"
       _              _      _                              _ 
       | |            | |    | |                            | | 
     __| |  __ _  ___ | |__  | |__    ___    __ _  _ __   __| | 
    / _` | / _` |/ __|| '_ \ | '_ \  / _ \  / _` || '__| / _` | 
   | (_| || (_| |\__ \| | | || |_) || (_) || (_| || |   | (_| | 
    \__,_| \__,_||___/|_| |_||_.__/  \___/  \__,_||_|    \__,_| 

EOF

    current_cpu=$(get_cpu_usage)
    current_ram=$(get_ram)
    current_temp=$(get_temp)

    cpu_line="Utilisation global (CPU): $(colorize "$current_cpu" 60 100 "%")"
    temp_line="La temperature est : $(colorize "$current_temp" 40 80 "°C")"

    Date="Date : $(get_date)"
    printf "%*s\n" $(( (${#Date} + $(tput cols)) / 2)) "$Date"

    Time="Uptime : $(get_time)"
    printf "%*s\n" $(( (${#Time} + $(tput cols)) / 2)) "$Time"

    printf "%*s\n" $(( (${#cpu_line} + $(tput cols)) / 2)) "$cpu_line"

    #CPU="Utilisation globale :$(get_cpu_usage) %"
    #printf "%*s\n" $(( (${#CPU} + $(tput cols)) / 2)) "$CPU"

    Ram="RAM : $(get_ram)"
    printf "%*s\n" $(( (${#Ram} + $(tput cols)) / 2)) "$Ram"

    printf "%*s\n" $(( (${#temp_line} + $(tput cols)) / 2)) "$temp_line"

    #Temp="La température est : $(get_temp) °C"
    #printf "%*s\n" $(( (${#Temp} + $(tput cols)) / 2)) "$Temp"

    Batterie="Batterie : $(get_batterie)"
    printf "%*s\n" $(( (${#Batterie} + $(tput cols)) / 2)) "$Batterie"

    Disque="Memoire : $(get_disque) % utilise"
    printf "%*s\n" $(( (${#Disque} + $(tput cols)) / 2)) "$Disque"
    sleep 1;
done
