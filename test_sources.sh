brew install jq curl
jq --version
# Expected Output: jq-<version>

curl --version
# Expected Output: curl <version> (and other details)

# the script
#!/usr/bin/env bash

# test_sources.sh - Script to validate and update sources.json

# Exit immediately if a command exits with a non-zero status
set -e

# Path to sources.json
SOURCES_FILE="sources.json"

# Backup directory and log file
BACKUP_DIR="backup_sources"
LOG_FILE="removed_feeds.log"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Backup the current sources.json with a timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
cp "$SOURCES_FILE" "$BACKUP_DIR/sources_backup_$TIMESTAMP.json"

echo "[$(date)] Backup of sources.json created at $BACKUP_DIR/sources_backup_$TIMESTAMP.json" >> "$LOG_FILE"

# Temporary file to store updated sources
TEMP_FILE=$(mktemp)

# Initialize the temporary file with an empty JSON object
echo "{}" > "$TEMP_FILE"

# Initialize table header
printf "\n%-30s %-80s %-15s\n" "Source" "Feed URL" "Status"
printf "%-30s %-80s %-15s\n" "------" "--------" "------"

# Function to check if a URL is accessible and returns valid XML
check_feed() {
    local url="$1"
    # Use curl to fetch the URL silently and get HTTP status code
    # Fetch first 1000 bytes to check for XML
    HTTP_RESPONSE=$(curl -s -w "%{http_code}" -m 10 --max-time 15 "$url" -o temp_feed.xml)
    HTTP_STATUS=${HTTP_RESPONSE: -3}
    # Check if status code is 200
    if [[ "$HTTP_STATUS" -ne 200 ]]; then
        return 1
    fi
    # Check if the content is XML (basic check)
    if grep -q "<?xml" temp_feed.xml; then
        return 0
    else
        return 1
    fi
}

# Iterate over each source in sources.json
jq -r 'keys[]' "$SOURCES_FILE" | while read -r source; do
    # Get all RSS URLs for the current source
    feeds=$(jq -r --arg src "$source" '.[$src].rss[]' "$SOURCES_FILE")
    # Initialize an array to hold valid feeds
    valid_feeds=()
    # Iterate over each feed URL
    while read -r feed_url; do
        if check_feed "$feed_url"; then
            # Feed is valid
            valid_feeds+=("$feed_url")
            # Print table row
            printf "%-30s %-80s %-15s\n" "$source" "$feed_url" "Valid"
        else
            # Feed is invalid
            echo "    ❌ Feed is invalid or inaccessible. Removing from sources.json."
            echo "[$(date)] Removed feed: $feed_url from source: $source" >> "$LOG_FILE"
            # Print table row
            printf "%-30s %-80s %-15s\n" "$source" "$feed_url" "Invalid"
            # Optionally, remove the temp_feed.xml file if it exists
            [ -f temp_feed.xml ] && rm temp_feed.xml
        fi
    done <<< "$feeds"

    # If there are valid feeds, add them to the TEMP_FILE
    if [ ${#valid_feeds[@]} -gt 0 ]; then
        # Convert the valid_feeds array to JSON array
        feeds_json=$(printf '%s\n' "${valid_feeds[@]}" | jq -R . | jq -s .)
        # Add the source and its valid feeds to the TEMP_FILE
        jq --arg src "$source" --argjson feeds "$feeds_json" '. + {($src): {rss: $feeds}}' "$TEMP_FILE" > "${TEMP_FILE}.tmp" && mv "${TEMP_FILE}.tmp" "$TEMP_FILE"
    else
        # If no valid feeds, remove the entire source
        echo "  ❌ All feeds for source: $source are invalid. Removing the source."
        echo "[$(date)] Removed entire source: $source due to no valid feeds." >> "$LOG_FILE"
    fi
done

# Replace the original sources.json with the updated TEMP_FILE
mv "$TEMP_FILE" "$SOURCES_FILE"

echo "\n[$(date)] sources.json has been updated."

# Clean up temporary files
[ -f temp_feed.xml ] && rm temp_feed.xml

echo "[$(date)] All invalid feeds and sources have been removed and logged in $LOG_FILE."
