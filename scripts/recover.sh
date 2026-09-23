#!/bin/bash

CONTAINER="self-healing-app"
URL="http://localhost:5000/api/health"

echo "================================="
echo " Self-Healing Recovery System"
echo "================================="

echo "Checking application..."

if curl -f "$URL" > /dev/null 2>&1
then
    echo "Application is healthy."
    exit 0
fi

echo "Application is unhealthy!"
echo "Starting recovery..."

echo "Restarting container..."

docker restart "$CONTAINER"

echo "Waiting for application to start..."

sleep 10

echo "Verifying recovery..."

if curl -f "$URL" > /dev/null 2>&1
then
    echo "Recovery successful!"
    echo "Application is healthy again."
    exit 0
else
    echo "Recovery failed!"
    echo "Application is still unhealthy."
    exit 1
fi