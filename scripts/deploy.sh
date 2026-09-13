#!/bin/bash

set -e

docker-compose down

docker-compose pull

docker-compose up -d --force-recreate

docker image prune -f