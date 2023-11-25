#!/bin/bash

# Define the directory and size thresholds
directory="/home/user/post"
min_size=$((6*1024*1024*1024)) # 6GB in bytes
max_size=$((7*1024*1024*1024)) # 7GB in bytes

# Start an infinite loop
while true; do
  # Get the directory size in bytes
  directory_size=$(du -sb $directory | cut -f1)

  # Check if the directory size is within the specified range
  if [ "$directory_size" -ge "$min_size" ] && [ "$directory_size" -le "$max_size" ]; then
    echo "The $directory directory size is between 6GB and 7GB."

    # Get the PID of the postcli process
    pid=$(pidof postcli)

    if [ -n "$pid" ]; then
      echo "Pausing postcli with PID $pid."
      kill -STOP $pid
      # Once stopped, you might want to break the loop or the script will keep pausing it every 30 seconds
      # break
    else
      echo "No postcli process found."
    fi
  else
    echo "The directory size is not in the 8GB to 10GB range."
  fi

  # Wait for 30 seconds before checking again
  sleep 30
done
