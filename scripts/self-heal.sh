#!/bin/bash

# ==================================================
# PATHS
# ==================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/health-check-lib.sh"

# Change this to the directory containing docker-compose.yml
COMPOSE_DIR="/home/ubuntu"


# ==================================================
# LOGGING
# ==================================================

log() {
    printf "%s %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$1"
}


# ==================================================
# RESTART DOCKER COMPOSE SERVICE
# ==================================================

restart_service() {

    local service="$1"

    log "[ACTION] Restarting $service..."

    if cd "$COMPOSE_DIR" && docker-compose restart "$service"; then

        log "[SUCCESS] $service restart command completed."

        return 0

    else

        log "[FAILED] Could not restart $service."

        return 1

    fi
}


# ==================================================
# CHECK NGINX
# ==================================================

if check_nginx; then

    log "[OK] Nginx is healthy."

else

    log "[FAILED] Nginx is down."
    log "[ACTION] Restarting Nginx..."

    if sudo systemctl restart nginx; then

        if check_nginx; then
            log "[SUCCESS] Nginx recovered."
        else
            log "[FAILED] Nginx restart completed, but health check failed."
        fi

    else

        log "[FAILED] Could not restart Nginx."

    fi

fi


# ==================================================
# CHECK DOCKER
# ==================================================

if check_docker; then

    log "[OK] Docker is healthy."

else

    log "[FAILED] Docker is down."
    log "[ACTION] Restarting Docker..."

    if sudo systemctl restart docker; then

        if check_docker; then
            log "[SUCCESS] Docker recovered."
        else
            log "[FAILED] Docker restart completed, but health check failed."
        fi

    else

        log "[FAILED] Could not restart Docker."

    fi

fi


# ==================================================
# CHECK FRONTEND
# ==================================================

if check_frontend; then

    log "[OK] Frontend is healthy."

else

    log "[FAILED] Frontend is unavailable."

    if restart_service "frontend"; then

        if check_frontend; then
            log "[SUCCESS] Frontend recovered."
        else
            log "[FAILED] Frontend restart completed, but health check failed."
        fi

    fi

fi


# ==================================================
# CHECK BACKEND
# ==================================================

if check_backend; then

    log "[OK] Backend is healthy."

else

    log "[FAILED] Backend is unavailable."

    if restart_service "backend"; then

        if check_backend; then
            log "[SUCCESS] Backend recovered."
        else
            log "[FAILED] Backend restart completed, but health check failed."
        fi

    fi

fi


# ==================================================
# FINAL HEALTH CHECK
# ==================================================

log "=========================================="
log "       RUNNING FINAL HEALTH CHECK"
log "=========================================="


if check_all; then

    log "[SUCCESS] Server is healthy after self-healing."

    exit 0

else

    log "[FAILED] Server is still unhealthy."
    log "[WARNING] Manual investigation required."

    exit 1

fi