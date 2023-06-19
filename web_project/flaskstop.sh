#!/bin/bash

# Find the process IDs (PIDs) of the processes running on port 5000
PIDS=$(sudo lsof -t -i :8000)

if [ -z "$PIDS" ]; then
  echo "No processes found running on port 8000"
else
  for PID in $PIDS; do
    sudo kill -9 $PID
    echo "Process with PID $PID has been terminated"
  done
fi
