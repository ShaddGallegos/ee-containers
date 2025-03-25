#!/bin/bash
# Set variables
CONFIG_PATH="/root/.ansible/vars/config"
LOG_FILE="/root/.ansible/vars/token_refresh.log"

# Create log directory if it doesn't exist
mkdir -p "$(dirname $LOG_FILE)"

# Create log entry for this run
echo "===== Token refresh attempt started at $(date) =====" >> $LOG_FILE

# Check if config file exists
if [ ! -f "$CONFIG_PATH" ]; then
  echo "ERROR: Config file not found at $CONFIG_PATH" >> $LOG_FILE
  exit 1
fi

# Extract refresh token from config
REFRESH_TOKEN=$(grep "automation_hub_token" "$CONFIG_PATH" | cut -d "'" -f 2)

if [ -z "$REFRESH_TOKEN" ]; then
  echo "ERROR: No token found in config file" >> $LOG_FILE
  exit 1
fi

# Make token refresh request
echo "Making token refresh request..." >> $LOG_FILE
RESPONSE=$(curl https://sso.redhat.com/auth/realms/redhat-external/protocol/openid-connect/token \
  -d grant_type=refresh_token \
  -d client_id="cloud-services" \
  -d refresh_token="$REFRESH_TOKEN" \
  --fail \
  --silent \
  --show-error 2>&1)

# Check result
if [ $? -eq 0 ]; then
  echo "SUCCESS: Token refresh completed successfully" >> $LOG_FILE
  
  # Extract and update new token
  NEW_TOKEN=$(echo $RESPONSE | jq -r '.refresh_token')
  if [ "$NEW_TOKEN" != "null" ] && [ -n "$NEW_TOKEN" ]; then
    # Create a backup of the config
    cp "$CONFIG_PATH" "${CONFIG_PATH}.bak"
    
    # Replace the token in the config file
    sed -i "s|automation_hub_token: '$REFRESH_TOKEN'|automation_hub_token: '$NEW_TOKEN'|g" "$CONFIG_PATH"
    echo "Token updated in config file" >> $LOG_FILE
  else
    echo "WARNING: Response didn't contain a valid refresh token" >> $LOG_FILE
  fi
else
  echo "ERROR: Token refresh failed" >> $LOG_FILE
  echo "Response: $RESPONSE" >> $LOG_FILE
fi

echo "===== Token refresh attempt completed at $(date) =====" >> $LOG_FILE
echo "" >> $LOG_FILE
