#!/bin/bash

SERVICE_FILE="${SERVICE_FILE:-src/Service.php}"
HOT_RELOAD="${HOT_RELOAD:-true}"

echo "======================================"
echo "  Development Environment"
echo "======================================"
echo "Service file: $SERVICE_FILE"
echo "Hot reload: $HOT_RELOAD"
echo "======================================"

# Function to start the application
start_app() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting application..."
    vendor/bin/mononoke "$SERVICE_FILE" &
    APP_PID=$!
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Application started with PID: $APP_PID"
}

# Function to stop the application
stop_app() {
    if [ ! -z "$APP_PID" ] && kill -0 $APP_PID 2>/dev/null; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Stopping application (PID: $APP_PID)..."
        kill -TERM $APP_PID 2>/dev/null

        # Wait for graceful shutdown (max 5 seconds)
        for i in {1..5}; do
            if ! kill -0 $APP_PID 2>/dev/null; then
                break
            fi
            sleep 1
        done

        # Force kill if still running
        if kill -0 $APP_PID 2>/dev/null; then
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] Forcing application shutdown..."
            kill -KILL $APP_PID 2>/dev/null
        fi

        wait $APP_PID 2>/dev/null
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Application stopped"
    fi
}

# Cleanup on exit
cleanup() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Shutting down..."
    stop_app
    exit 0
}

trap cleanup SIGTERM SIGINT

# Start the application initially
start_app

if [ "$HOT_RELOAD" = "true" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Hot reload enabled. Watching /app/src/ for changes..."

    # Watch for changes and restart
    inotifywait -m -r -e modify,create,delete,move /app/src/ --exclude '.*\.swp$|.*\.swx$|.*~$|.*\.tmp$' |
        while read -r directory events filename; do
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] Detected $events: $directory$filename"
            stop_app
            sleep 0.5
            start_app
        done
else
    # Just wait for the application to finish
    wait $APP_PID
fi