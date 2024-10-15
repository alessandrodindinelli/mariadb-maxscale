#!/bin/bash

# Prerequisites
# ---
# mariadb -hmaxscale -uroot -pPassword1!
# CREATE DATABASE poc_maxscale;
# USE poc_maxscale;
# CREATE TABLE t (a int);
# ---

# Database connection parameters, enable the needed DB_HOST
DB_NAME="poc_maxscale"
DB_USER="sky-admin"
DB_PASSWORD="yD9Xg\$Ryce^6f2"
# DB_HOST="mariadb-svc-0"
DB_HOST="maxscale"
DB_PORT="3306"

# Test parameters
DURATION=120  # Duration in seconds
MAX_CONCURRENT=20  # Maximum number of concurrent queries

echo "Started execution script ..."

# Function to run a single query
run_query() {
    mariadb -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" -se "INSERT INTO t (a) VALUES (SLEEP(10));"
}

# Cicle execution
start_time=$(date +%s)
end_time=$((start_time + DURATION))

# Array to keep track of background process PIDs
pids=()

while true; do
    current_time=$(date +%s)
    if [ "$current_time" -ge "$end_time" ]; then
        break
    fi

    # Start new queries if we're below MAX_CONCURRENT
    while [ ${#pids[@]} -lt $MAX_CONCURRENT ]; do
        run_query &
        pids+=($!)

        # Check if we've reached the end time
        current_time=$(date +%s)
        if [ "$current_time" -ge "$end_time" ]; then
            break 2
        fi
    done

    # Check for completed processes and remove them from the array
    for pid in "${pids[@]}"; do
        if ! kill -0 $pid 2>/dev/null; then
            pids=(${pids[@]/$pid})
        fi
    done

    # Short sleep to prevent busy-waiting
    sleep 0.1
done

# Wait for all remaining processes to finish
for pid in "${pids[@]}"; do
    wait $pid
done

echo "Test completed!"
