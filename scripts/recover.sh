
#!/bin/bash

CONTAINER="self-healing-app"
URL="http://localhost:5000/api/health"

MAX_ATTEMPTS=3
WAIT_TIME=10

LOG_FILE="./logs/incidents.log"

echo "========================================"
echo "       SELF-HEALING RECOVERY"
echo "========================================"

# Function to write incident logs
log_incident() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

echo "Checking application..."

if curl -f "$URL" > /dev/null 2>&1
then
    echo "Application is healthy."
    exit 0
fi

echo "Application is unhealthy!"

log_incident "FAILURE DETECTED | SERVICE=$CONTAINER"

for attempt in $(seq 1 $MAX_ATTEMPTS)
do

    echo ""
    echo "Recovery attempt $attempt/$MAX_ATTEMPTS"

    log_incident "RECOVERY ATTEMPT=$attempt | SERVICE=$CONTAINER"

    echo "Restarting container..."

    docker restart "$CONTAINER"

    echo "Waiting $WAIT_TIME seconds..."

    sleep $WAIT_TIME

    echo "Checking application..."

    if curl -f "$URL" > /dev/null 2>&1
    then

        echo ""
        echo "========================================"
        echo "       RECOVERY SUCCESSFUL"
        echo "========================================"

        log_incident "RECOVERY SUCCESS | ATTEMPT=$attempt | SERVICE=$CONTAINER"

        exit 0

    else

        echo "Recovery attempt $attempt failed."

        log_incident "RECOVERY FAILED | ATTEMPT=$attempt | SERVICE=$CONTAINER"

    fi

done

echo ""
echo "========================================"
echo "       RECOVERY FAILED"
echo "========================================"
echo "Maximum recovery attempts reached."
echo "Manual intervention required."

log_incident "CRITICAL | AUTOMATIC RECOVERY FAILED | SERVICE=$CONTAINER"

exit 1