#!/bin/bash

# Base directory where team folders are located
BASE_DIR="."

# Iterate through team_0 to team_20
for i in {0..20}; do
    TEAM_DIR="${BASE_DIR}/team_${i}/certificates"
    
    # Check if the certificates directory exists
    if [ -d "$TEAM_DIR" ]; then
        CERT_FILE="${TEAM_DIR}/cert.crt"
        KEY_FILE="${TEAM_DIR}/private.key"
        OUTPUT_FILE="${BASE_DIR}/team_${i}_keypair.crt"

        # Ensure both files exist before concatenating
        if [[ -f "$CERT_FILE" && -f "$KEY_FILE" ]]; then
            # Concatenate cert.crt and private.key into combined.crt
            cat "$CERT_FILE" "$KEY_FILE" > "$OUTPUT_FILE"
            echo "Combined files for team_${i} into $OUTPUT_FILE"
        else
            echo "Missing cert.crt or private.key in $TEAM_DIR"
        fi
    else
        echo "Directory $TEAM_DIR does not exist"
    fi
done
