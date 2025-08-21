#!/bin/bash

HOST_ENTRY="k3s.local"
HOSTS_FILE="/etc/hosts"

echo "[+] Removing lines matching '$HOST_ENTRY' from $HOSTS_FILE"

# Backup before change
cp "$HOSTS_FILE" "$HOSTS_FILE.bak"

# Delete lines containing the host entry
sed -i '' "/${HOST_ENTRY//./\\.}/d" "$HOSTS_FILE"

echo "[+] Done. Backup saved as $HOSTS_FILE.bak"
