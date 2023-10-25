#!/bin/bash

# This script removes dangling images.
# Using crontab this script will execute weekly on 5.0 am.


# Creates a var to generate the container id of dangling images.
DANGLING_IMAGES=$(docker images --filter "dangling=true" -q)

# Creates a var to calculate the count of dangling images.
COUNT=$( $DANGLING_IMAGES | wc -c)

# Creates a var to generate the disk useage before removing dangling images.
DISK_USAGE_BEFORE=$(docker system df --format "{{.Size}}" | tail -n1)

# Creates two vars called log_file and log_dir to specify the path of log file and foulder for the script.
LOG_FILE="/opt/scripts/remove_dangling_images.log"
LOG_DIR= "/opt/scripts"
# Check if the directory is exist
if [ ! -d "$LOG_DIR" ]; then
  mkdir "$LOG_DIR"
fi

# Check if the log file exists
if [ ! -f "$LOG_FILE" ]; then
  touch "$LOG_FILE"
fi

if [ "$COUNT" -ne 0 ]; then
  # Removes dangling images.
  docker rmi $(DANGLING_IMAGES)

  # Creates a var to regenerate the  disk useage after removing dangling images.
  DISK_USAGE_AFTER=$(docker system df --format "{{.Size}}" | tail -n1)


  # Creates a var called timestamp to use in the log file.
  TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

  # Adding the result into the log file
  echo "[$TIMESTAMP] Removed $COUNT dangling images. Disk usage was $DISK_USAGE_BEFORE and freed to $DISK_USAGE_AFTER." >> "$LOG_FILE"
else

  # Log a message indicating that there were no dangling images
  TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
  echo "[$TIMESTAMP] No dangling images found. Nothing removed." >> "$LOG_FILE"
fi
