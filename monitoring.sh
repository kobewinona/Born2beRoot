#!/bin/bash

arc=$(uname -a)

phys_cpu=$(grep 'physical id' /proc/cpuinfo | sort -u | wc -l)
virt_cpu=$(grep 'processor' /proc/cpuinfo | sort -u | wc -l)

free_mem=$(free -m | awk '$1 == "Mem:" {print $2}')
used_mem=$(free -m | awk '$1 == "Mem:" {print $3}')
used_mem_pct=$(free | awk '$1 == "Mem:" {printf("%.2f%%"), $3/$2*100}')

free_strg=$(df -BG | grep '^/dev/' | grep -v '/boot$' | awk '{fst += $2} END {print fst}')
used_strg=$(df -BM | grep '^/dev/' | grep -v '/boot$' | awk '{ust += $3} END {print ust}')
used_strg_pct=$(df -BM | grep '^/dev/' | grep -v '/boot$' | awk '{ust += $3} {fst+= $2} END {printf("%d%%"), ust/fst*100}')

cpu_load=$(mpstat -n 2 4 | grep -i 'average' | awk '{printf("%.1f%%"), $3+$4+$5+$6+$7+$8+$9+$10+$11}')
last_boot=$(uptime -s | xargs -I {} date -d {} '+%Y-%m-%d %H:%M')

is_lvm_active=$(lsblk -l -o TYPE,MOUNTPOINT | grep 'lvm' | awk '$2 != "" {print "yes"; exit} END {if (NR == 0) print "no"}')

tcp_connects=$(ss -t | sed '1d' | wc -l | awk '{printf("%d ESTABLISHED"), $1}')

users_connected=$(who | wc -l)

server_ip=$(ip -f inet -o address show | awk '$2 != "lo" { gsub(/\/.*/, "", $4); print $4 }')
server_mac=$(ip -f link -o address show | grep 'ether' | awk '{ print $15 }')
sudo_comms_count=$(journalctl _COMM=sudo | grep COMMAND | wc -l)

wall "	#Architecture: ${arc}
	#CPU physical: ${phys_cpu}
	#vCPU: ${virt_cpu}
	#Memory Usage: ${used_mem}/${free_mem}MB (${used_mem_pct}%)
	#Disk Usage: ${used_strg}/${free_strg}Gb (${used_strg_pct}%)
	#CPU load: ${cpu_load} ${cpu_load_w_delay}
	#Last boot: ${last_boot}
	#LVM use: ${is_lvm_active}
	#Connections TCP: ${tcp_connects}
	#User log: ${users_connected}
	#Network: IP ${server_ip} (${server_mac})
	#Sudo: ${sudo_comms_count} cmd"

exit
