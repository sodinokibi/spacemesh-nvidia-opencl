#!/bin/bash
set -e


# Setup SSH authorized_keys if avain_ssh is provided
if [ -n "$avain_ssh" ]; then
    mkdir -p /root/.ssh
    echo "$avain_ssh" > /root/.ssh/authorized_keys
    chmod 700 /root/.ssh
    chmod 600 /root/.ssh/authorized_keys
fi
# Start the SSH daemon
/usr/sbin/sshd


# Start monitor.sh in the background to check the folder size and manage the postcli process
/monitor.sh &

python3 /smesher-plot-speed/smesher-plot-speed.py /home/user/post &
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
