#!/bin/sh

# Ensure the script is executable
chmod +x "$0"

# Set the project directory to three directories back from where the script resides
PROJECT_DIR=$(dirname $(dirname $(dirname $(dirname $(realpath $0)))))

# Debugging: Print the resolved project directory
echo "Resolved PROJECT_DIR: $PROJECT_DIR"

# Autodetect date, time, and timezone
CURRENT_DATE=$(date "+%m/%d/%Y")
CURRENT_TIME=$(date "+%I:%M:%S %p")
LOCAL_TZ=$(date "+%Z")
IANA_TZ=$(timedatectl show --value --property Timezone)

# Autodetect PUID and PGID
PUID=$(id -u)
PGID=$(id -g)

# Ensure .env exists
if [ ! -f "$PROJECT_DIR/.env" ]; then
  echo "Copying .env.example to .env..."
  cp "$PROJECT_DIR/.env.example" "$PROJECT_DIR/.env"
  echo ".env file created."
fi

# Remove any existing SURGE CONFIGURATION header with generated date and time
sed -i "/^# SURGE CONFIGURATION - Generated on/d" "$PROJECT_DIR/.env"

# Add the SURGE CONFIGURATION header with the generated date and time in local timezone
sed -i "1s|^# ===========================================|# ===========================================\n# SURGE CONFIGURATION - Generated on $CURRENT_DATE - $CURRENT_TIME $LOCAL_TZ|" "$PROJECT_DIR/.env"

# Update .env with IANA timezone, PUID, and PGID
grep -q "^TZ=" "$PROJECT_DIR/.env" && sed -i "s|^TZ=.*|TZ=$IANA_TZ|" "$PROJECT_DIR/.env" || echo "TZ=$IANA_TZ" >> "$PROJECT_DIR/.env"
grep -q "^PUID=" "$PROJECT_DIR/.env" && sed -i "s|^PUID=.*|PUID=$PUID|" "$PROJECT_DIR/.env" || echo "PUID=$PUID" >> "$PROJECT_DIR/.env"
grep -q "^PGID=" "$PROJECT_DIR/.env" && sed -i "s|^PGID=.*|PGID=$PGID|" "$PROJECT_DIR/.env" || echo "PGID=$PGID" >> "$PROJECT_DIR/.env"
