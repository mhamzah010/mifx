#!/bin/bash
# Simple logrotate script in Bash
# Usage: ./scripts/logrotate.sh /path/to/logs ./logrotate.log

LOG_DIR="$1"
LOG_FILE="$2"
MAX_SIZE=$((5 * 1024 * 1024))  # 5 MB in bytes
DATE=$(date +"%Y%m%d-%H%M%S")

if [ -z "$LOG_DIR" ] || [ -z "$LOG_FILE" ]; then
  echo "Usage: $0 /path/to/logs /path/to/logfile"
  exit 1
fi

for file in "$LOG_DIR"/*.log; do
  [ -e "$file" ] || continue  # skip if no .log files
  FILE_SIZE=$(stat -c%s "$file")
  if [ "$FILE_SIZE" -gt "$MAX_SIZE" ]; then
    ARCHIVE="${file}-${DATE}.gz"
    gzip -c "$file" > "$ARCHIVE"
    : > "$file"  # truncate file
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Rotated $file ($FILE_SIZE bytes) -> $ARCHIVE" >> "$LOG_FILE"
  fi
done
