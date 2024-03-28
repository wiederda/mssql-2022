#!/bin/bash

# Define variables
CONTAINER_NAME=""
BACKUP_DIR=""
DATABASE_NAME=""
BACKUP_FILE="$BACKUP_DIR/$DATABASE_NAME-$(date +%Y-%m-%d_%H-%M-%S).bak"
GOTIFY_URL=""
GOTIFY_TOKEN=""

# Run backup command inside the container
docker exec $CONTAINER_NAME /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "YouPass" -Q "BACKUP DATABASE $DATABASE_NAME TO DISK='$BACKUP_F>

# Check if backup was successful
if [ $? -eq 0 ]; then
  # Backup successful, send notification to Gotify
  curl -X POST "$GOTIFY_URL/message?token=$GOTIFY_TOKEN" -F "title=Database Backup" -F "message=Backup of $DATABASE_NAME completed successfully."
else
  # Backup failed, send error notification to Gotify
  curl -X POST "$GOTIFY_URL/message?token=$GOTIFY_TOKEN" -F "title=Database Backup Error" -F "message=Failed to backup $DATABASE_NAME. Check logs for details."
fi