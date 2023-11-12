#!/bin/bash
set -e

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

# Following the postcli command, you might want to keep the container running,
# hence the `bash` at the end. Adjust according to your needs.
exec "$@"
