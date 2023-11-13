#!/bin/bash
set -e


# Start vsftpd FTP server
/run_vsftpd.sh &

# Start rclone serve in the background to serve the /home/user/post directory over HTTP on port 8080
rclone serve http /home/user/post --addr :8081 &

# Initialize PoST data using the environment variables
postcli -provider $PROVIDER \
        -commitmentAtxId $COMMITMENT_ATX_ID \
        -id $ID \
        -labelsPerUnit $LABELS_PER_UNIT \
        -maxFileSize $MAX_FILE_SIZE \
        -numUnits $NUM_UNITS \
        -datadir $DATADIR \
        -fromFile $RANGE_START \
        -toFile $RANGE_END

# Following the postcli command, we run the command passed to the docker run
# This will typically be a long-running command to keep the container alive
exec "$@"
