#!/bin/bash

CONTAINER="self-healing-app"
URL="http://localhost:5000/api/health"

MAX_ATTEMPTS=3
WAIT_TIME=10

LOG_FILE="./logs/incidents.log"
METRICS_FILE="./metrics/metrics.log"

START_TIME=$(date +%s)

log_incident() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log_metric() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$METRICS_FILE"
}

echo "========================================"
echo "       SELF-HEALING RECOVERY"
echo "========================================"

echo "Checking application..."

if curl -f "$URL" > /dev/null 2>&1
then
    echo "Application is healthy."
    exit 0
fi

echo "Application is unhealthy!"

log_incident "FAILURE DETECTED | SERVICE=$CONTAINER"
log_metric "health_check_failure_total=1"

for attempt in $(seq 1 $MAX_ATTEMPTS)
do

    echo ""
    echo "Recovery attempt $attempt/$MAX_ATTEMPTS"

    log_incident "RECOVERY ATTEMPT=$attempt | SERVICE=$CONTAINER"
    log_metric "recovery_attempt_total=1"

    echo "Restarting container..."

    docker restart "$CONTAINER"

    echo "Waiting $WAIT_TIME seconds..."

    sleep $WAIT_TIME

    echo "Checking application..."

    if curl -f "$URL" > /dev/null 2>&1
    then

        END_TIME=$(date +%s)
        RECOVERY_TIME=$((END_TIME - START_TIME))

        echo ""
        echo "========================================"
        echo "       RECOVERY SUCCESSFUL"
        echo "========================================"
        echo "Recovery time: ${RECOVERY_TIME}s"

        log_incident "RECOVERY SUCCESS | ATTEMPT=$attempt | RECOVERY_TIME=${RECOVERY_TIME}s"
        log_metric "recovery_success_total=1"
        log_metric "recovery_time_seconds=$RECOVERY_TIME"

        exit 0

    else

        echo "Recovery attempt $attempt failed."

        log_incident "RECOVERY FAILED | ATTEMPT=$attempt | SERVICE=$CONTAINER"
        log_metric "recovery_failure_total=1"

    fi

done

echo ""
echo "========================================"
echo "       RECOVERY FAILED"
echo "========================================"

log_incident "CRITICAL | AUTOMATIC RECOVERY FAILED | SERVICE=$CONTAINER"
log_metric "recovery_escalation_total=1"

exit 1