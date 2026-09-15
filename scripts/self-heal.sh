#!/bin/bash

source "./health-check-lib.sh"


# ==================================================
# LOGGING
# ==================================================

log() {
    printf "%s %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$1"
}

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
    log "[ACTION] Restarting frontend..."

    if docker compose restart frontend; then

        if check_frontend; then
            log "[SUCCESS] Frontend recovered."
        else
            log "[FAILED] Frontend restart completed, but health check failed."
        fi

    else

        log "[FAILED] Could not restart frontend."

    fi

fi


# ==================================================
# CHECK BACKEND
# ==================================================

if check_backend; then

    log "[OK] Backend is healthy."

else

    log "[FAILED] Backend is unavailable."
    log "[ACTION] Restarting backend..."

    if docker compose restart backend; then

        if check_backend; then
            log "[SUCCESS] Backend recovered."
        else
            log "[FAILED] Backend restart completed, but health check failed."
        fi

    else

        log "[FAILED] Could not restart backend."

    fi

fi


if check_all; then

    log "[SUCCESS] Server is healthy after self-healing."

else

    log "[FAILED] Server is still unhealthy."
    log "[WARNING] Manual investigation required."

fi
