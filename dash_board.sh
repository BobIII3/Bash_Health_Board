#!/usr/bin/env bash

echo "            ***********************************                "
echo "            *                                 *                "
echo "            *           Dash Board            *                "
echo "            *                                 *                "
echo "            ***********************************                "


echo "    Date : $(date)    "
echo "    Uptime : $(uptime -p | sed 's/up //')  "


# Récupère la charge de la dernière minute
CHARGE_1MIN=$(uptime | awk -F'load average:' '{ print $2 }' | cut -d',' -f1)
NB_COEURS=$(nproc)

# Calcul du pourcentage (via 'bc' pour avoir des décimales)
UTILISATION=$(echo "scale=3; ($CHARGE_1MIN / $NB_COEURS) * 100" | bc)

echo "    Utilisation globale : $UTILISATION %"

echo "    RAM : $(free -h | grep Mem | awk '{print $3 " / " $2}')"

TEMP=$(cat /sys/class/thermal/thermal_zone*/temp | awk '{sum += $1; n++} END {if (n > 0) printf "%.1f", (sum / n)/1000 ; }' )

echo "    La température est : $TEMP °C"

BATTERIE=$( upower -i $( upower -e | grep BAT) | grep percentage | awk '{ print $2 }' )

echo "    Batterie : $BATTERIE "


MEMOIRE=$(df -h | grep /dev/nvme0n1p7 | awk '{printf "%.1f", ($3 / $2)*100 }')

echo "    Memoire : $MEMOIRE % utilise"

