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

colorize_inverse () {
    
    local val=$1
    local orange=$2
    local red=$3
    local suffix=$4

    local int_val=${val%[.,%]*}

    if [ "$int_val" -le "$orange" ]; then
        echo -e "${ORANGE}${val}${suffix}${NC}"
    elif [ "$int_val" -le "$red" ]; then
        echo -e "${RED}${val}${suffix}${NC}"
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
    current_batterie=$(get_batterie)
    current_disque=$(get_disque)
    current_ram=$(get_ram)

    current_date=$(get_date)
    current_time=$(get_time)

    cpu_line="Utilisation global (CPU): $(colorize "$current_cpu" 60 100 "%")"
    ram_line="Utilisation de la RAM : $(colorize "$current_ram" 6 14 "")"
    temp_line="La temperature est : $(colorize "$current_temp" 40 80 "°C")"
    batterie_line="Le niveau de batterie est : $(colorize_inverse "$current_batterie" 50 10 "")"
    disque_line="Memoire utilise a : $(colorize "$current_disque" 50 70 "%")"

    date_line="Date : $current_date"
    time_line="Uptime : $current_time"

    printf "%*s\n" $(( (${#date_line} + $(tput cols)) / 2)) "$date_line"

    printf "%*s\n" $(( (${#time_line} + $(tput cols)) / 2)) "$time_line"

    printf "%*s\n" $(( (${#cpu_line} + $(tput cols)) / 2)) "$cpu_line"

    printf "%*s\n" $(( (${#ram_line} + $(tput cols)) / 2)) "$ram_line"

    printf "%*s\n" $(( (${#temp_line} + $(tput cols)) / 2)) "$temp_line"

    printf "%*s\n" $(( (${#batterie_line} + $(tput cols)) /2)) "$batterie_line"

    printf "%*s\n" $(( (${#batterie_line} + $(tput cols)) / 2)) "$disque_line"

    
    sleep 5;
done
