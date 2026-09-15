#!/bin/bash

# ==================================================
# HEALTH CHECK FUNCTIONS
# ==================================================

check_nginx() {
    systemctl is-active --quiet nginx
}

check_docker() {
    systemctl is-active --quiet docker
}

check_frontend() {
    curl -fs http://localhost:3000/login > /dev/null
}

check_backend() {
    curl -fs http://localhost:3001/api/health > /dev/null
}

check_all() {
    check_nginx && check_docker && check_frontend && check_backend
}