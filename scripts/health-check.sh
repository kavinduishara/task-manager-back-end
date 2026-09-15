#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/health-check-lib.sh"

HEALTHY=true

printf "\n==========================================\n"
printf "           SERVER HEALTH CHECK\n"
printf "==========================================\n"

printf "\nSYSTEM\n"

printf "%-20s : %s\n" \
    "Memory Available" \
    "$(free | awk '/Mem:/ {printf "%.1f%%", 100 * $7 / $2}')"

printf "%-20s : %s\n" \
    "Disk Usage" \
    "$(df --total | awk '/total/ {print $5}')"

printf "%-20s : %s\n" \
    "Uptime" \
    "$(uptime -p)"

printf "%-20s : %s\n" \
    "Load Average" \
    "$(uptime | awk -F'load average: ' '{print $2}')"

printf "\nSERVICES\n"

if check_nginx; then
    printf "%-20s : %s\n" "Nginx" "OK"
else
    printf "%-20s : %s\n" "Nginx" "FAILED"
    HEALTHY=false
fi

if check_docker; then
    printf "%-20s : %s\n" "Docker" "OK"
else
    printf "%-20s : %s\n" "Docker" "FAILED"
    HEALTHY=false
fi

printf "\nAPPLICATIONS\n"

if check_frontend; then
    printf "%-20s : %s\n" "Frontend" "OK"
else
    printf "%-20s : %s\n" "Frontend" "FAILED"
    HEALTHY=false
fi

if check_backend; then
    printf "%-20s : %s\n" "Backend" "OK"
else
    printf "%-20s : %s\n" "Backend" "FAILED"
    HEALTHY=false
fi

printf "\n==========================================\n"

if [ "$HEALTHY" = true ]; then
    printf "             SERVER HEALTHY\n"
    printf "==========================================\n"
    exit 0
else
    printf "           SERVER UNHEALTHY\n"
    printf "==========================================\n"
    exit 1
fi