#!/usr/bin/env bash

#----Function-----

get_time () { date "+%A %d %B %Y | %H:%M"; }

get_uptime () {
       	read -r tot_seconde _ < /proc/uptime
	tot_seconde=${tot_seconde%.*}
	h=$(($tot_seconde/3600))
	min=$((($tot_seconde%3600) / 60))
	echo "$h h : $min min"
}

get_cpu_usage () {

	# Récupère la charge de la dernière minute
	CHARGE_1MIN=$(uptime | awk -F'load average:' '{ print $2 }' | cut -d',' -f1)
	NB_COEURS=$(nproc)

	# Calcul du pourcentage (via 'bc' pour avoir des décimales)
	echo "scale=3; ($CHARGE_1MIN / $NB_COEURS) * 100" | bc
}

get_temp (){
	cat /sys/class/thermal/thermal_zone*/temp | awk '{sum += $1; n++} END {if (n > 0) printf "%.1f", (sum / n)/1000 ; }'
}

get_batterie (){ cat /sys/class/power_supply/BAT*/capacity; }

get_disque() { df -h | grep /dev/nvme0n1p7 | awk '{printf "%.1f", ($3 / $2)*100 }'; }

#----Display----

echo "            ***********************************                "
echo "            *                                 *                "
echo "            *           Dash Board            *                "
echo "            *                                 *                "
echo "            ***********************************                "


echo "    Date : $(get_time)    "
echo "    Uptime : $(get_uptime)  "
echo "    Utilisation globale : $(get_cpu_usage) %"
echo "    RAM : $(free -h | grep Mem | awk '{print $3 " / " $2}')"
echo "    La température est : $(get_temp) °C"
echo "    Batterie : $(get_batterie) "
echo "    Memoire : $(get_disque) % utilise"
