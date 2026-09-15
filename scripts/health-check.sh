#!/bin/bash

# ============================================================
# SERVER HEALTH CHECK
# ============================================================

printf "\n==========================================\n"
printf "           SERVER HEALTH CHECK\n"
printf "==========================================\n"


# ============================================================
# SYSTEM INFORMATION
# ============================================================

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


# ============================================================
# HEALTH CHECK
# ============================================================

check_services_and_apps() {

    printf "\n[*] Checking services and applications...\n"


    # --------------------------------------------------------
    # NGINX
    # --------------------------------------------------------

    if systemctl is-active --quiet nginx; then
        NGINX_OK=true
        NGINX_STATUS="active"
    else
        NGINX_OK=false
        NGINX_STATUS="FAILED"
    fi


    # --------------------------------------------------------
    # DOCKER
    # --------------------------------------------------------

    if systemctl is-active --quiet docker; then
        DOCKER_OK=true
        DOCKER_STATUS="active"
    else
        DOCKER_OK=false
        DOCKER_STATUS="FAILED"
    fi


    # --------------------------------------------------------
    # FRONTEND
    # --------------------------------------------------------

    if curl -fs http://localhost:3000/login > /dev/null; then
        FRONTEND_OK=true
        FRONTEND_STATUS="OK"
    else
        FRONTEND_OK=false
        FRONTEND_STATUS="FAILED"
    fi


    # --------------------------------------------------------
    # BACKEND
    # --------------------------------------------------------

    if curl -fs http://localhost:3001/api/health > /dev/null; then
        BACKEND_OK=true
        BACKEND_STATUS="OK"
    else
        BACKEND_OK=false
        BACKEND_STATUS="FAILED"
    fi


    # --------------------------------------------------------
    # DISPLAY
    # --------------------------------------------------------

    printf "\nSERVICES\n"

    printf "%-20s : %s\n" \
        "Nginx" "$NGINX_STATUS"

    printf "%-20s : %s\n" \
        "Docker" "$DOCKER_STATUS"


    printf "\nAPPLICATIONS\n"

    printf "%-20s : %s\n" \
        "Frontend" "$FRONTEND_STATUS"

    printf "%-20s : %s\n" \
        "Backend" "$BACKEND_STATUS"
}


# ============================================================
# SELF HEAL
# ============================================================

self_heal() {

    printf "\n==========================================\n"
    printf "              SELF-HEALING\n"
    printf "==========================================\n"


    # --------------------------------------------------------
    # NGINX
    # --------------------------------------------------------

    if [ "$NGINX_OK" = false ]; then

        printf "\n[!] Nginx is unhealthy.\n"
        printf "[*] Restarting Nginx...\n"

        if sudo systemctl restart nginx; then
            printf "[+] Nginx restart command completed.\n"
        else
            printf "[!] Failed to restart Nginx.\n"
        fi

        printf "[*] Waiting for Nginx...\n"
        sleep 3

        printf "[*] Running health check again...\n"

        check_services_and_apps
    fi


    # --------------------------------------------------------
    # DOCKER
    # --------------------------------------------------------

    if [ "$DOCKER_OK" = false ]; then

        printf "\n[!] Docker is unhealthy.\n"
        printf "[*] Restarting Docker...\n"

        if sudo systemctl restart docker; then
            printf "[+] Docker restart command completed.\n"
        else
            printf "[!] Failed to restart Docker.\n"
        fi

        printf "[*] Waiting for Docker...\n"
        sleep 5

        printf "[*] Running health check again...\n"

        check_services_and_apps
    fi


    # --------------------------------------------------------
    # FRONTEND
    # --------------------------------------------------------

    if [ "$FRONTEND_OK" = false ]; then

        printf "\n[!] Frontend is still unhealthy.\n"
        printf "[*] Restarting frontend container...\n"

        if docker-compose restart frontend; then
            printf "[+] Frontend restart command completed.\n"
        else
            printf "[!] Failed to restart frontend container.\n"
        fi

        printf "[*] Waiting for frontend...\n"
        sleep 5

        printf "[*] Running health check again...\n"

        check_services_and_apps
    fi


    # --------------------------------------------------------
    # BACKEND
    # --------------------------------------------------------

    if [ "$BACKEND_OK" = false ]; then

        printf "\n[!] Backend is still unhealthy.\n"
        printf "[*] Restarting backend container...\n"

        if docker-compose restart backend; then
            printf "[+] Backend restart command completed.\n"
        else
            printf "[!] Failed to restart backend container.\n"
        fi

        printf "[*] Waiting for backend...\n"
        sleep 5

        printf "[*] Running health check again...\n"

        check_services_and_apps
    fi


    # --------------------------------------------------------
    # FINAL RESULT
    # --------------------------------------------------------

    printf "\n==========================================\n"
    printf "             FINAL STATUS\n"
    printf "==========================================\n"

    printf "%-20s : %s\n" "Nginx" "$NGINX_STATUS"
    printf "%-20s : %s\n" "Docker" "$DOCKER_STATUS"
    printf "%-20s : %s\n" "Frontend" "$FRONTEND_STATUS"
    printf "%-20s : %s\n" "Backend" "$BACKEND_STATUS"
}


# ============================================================
# INITIAL HEALTH CHECK
# ============================================================

check_services_and_apps


# ============================================================
# ARGUMENT / USER DECISION
# ============================================================

case "$1" in

    -y)

        printf "\n[*] Automatic self-healing enabled.\n"

        if [ "$NGINX_OK" = false ] || \
           [ "$DOCKER_OK" = false ] || \
           [ "$FRONTEND_OK" = false ] || \
           [ "$BACKEND_OK" = false ]; then

            self_heal

        else

            printf "\n[+] Everything is healthy.\n"
            printf "[*] No recovery is required.\n"

        fi

        ;;


    -n)

        printf "\n[*] Report-only mode.\n"
        printf "[*] No recovery will be performed.\n"

        ;;


    "")

        if [ "$NGINX_OK" = false ] || \
           [ "$DOCKER_OK" = false ] || \
           [ "$FRONTEND_OK" = false ] || \
           [ "$BACKEND_OK" = false ]; then

            printf "\n[!] One or more components are unhealthy.\n"

            read -r -p "[?] Attempt self-healing? (y/n): " ANSWER

            case "$ANSWER" in

                y|Y)
                    printf "\n[*] Self-healing requested.\n"
                    self_heal
                    ;;

                n|N)
                    printf "\n[*] Self-healing cancelled.\n"
                    printf "[*] No changes were made.\n"
                    ;;

                *)
                    printf "\n[!] Invalid response.\n"
                    printf "[*] No changes were made.\n"
                    ;;

            esac

        else

            printf "\n[+] Everything is healthy.\n"
            printf "[*] No recovery is required.\n"

        fi

        ;;


    *)

        printf "\n[!] Invalid argument: %s\n" "$1"

        printf "\nUsage:\n"
        printf "  ./healthcheck.sh       Check and ask before healing\n"
        printf "  ./healthcheck.sh -y    Check and automatically heal\n"
        printf "  ./healthcheck.sh -n    Check only, no healing\n"

        ;;

esac


# ============================================================
# COMPLETE
# ============================================================

printf "\n==========================================\n"
printf "             CHECK COMPLETE\n"
printf "==========================================\n"