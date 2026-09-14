#!/bin/bash

printf "\n==========================================\n"
printf "           SERVER HEALTH CHECK\n"
printf "==========================================\n"

# ---------------- SYSTEM ----------------

printf "\nSYSTEM\n"
printf "%-20s : %s\n" "Memory Available" "$(free | awk '/Mem:/ {printf "%.1f%%", 100 * $7 / $2}')"
printf "%-20s : %s\n" "Disk Usage" "$(df --total | awk '/total/ {print $5}')"
printf "%-20s : %s\n" "Uptime" "$(uptime -p)"
printf "%-20s : %s\n" "Load Average" "$(uptime | awk -F'load average: ' '{print $2}')"

# ---------------- SERVICES ----------------

printf "\nSERVICES\n"
printf "%-20s : %s\n" "Nginx" "$(systemctl is-active nginx)"
printf "%-20s : %s\n" "Docker" "$(systemctl is-active docker)"

# ---------------- APPLICATIONS ----------------

printf "\nAPPLICATIONS\n"

if curl -fs http://localhost:3000/login > /dev/null; then
    printf "%-20s : %s\n" "Frontend" "OK"
else
    printf "%-20s : %s\n" "Frontend" "FAILED"
fi

if curl -fs http://localhost:3001/api/health > /dev/null; then
    printf "%-20s : %s\n" "Backend" "OK"
else
    printf "%-20s : %s\n" "Backend" "FAILED"
fi

printf "\n==========================================\n"
printf "             CHECK COMPLETE\n"
printf "==========================================\n"