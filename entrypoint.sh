#!/bin/bash
set -e

SERVER_DIR="/home/dragonwilds/server"
CONFIG_DIR="${SERVER_DIR}/RSDragonwilds/Saved/Config/Linux"
CONFIG_FILE="${CONFIG_DIR}/DedicatedServer.ini"

# Default passwords at runtime (not baked into the image)
ADMIN_PASSWORD="${ADMIN_PASSWORD:-changeme}"
WORLD_PASSWORD="${WORLD_PASSWORD:-}"

# --- Install / update server files via SteamCMD ---
# Server files are downloaded at runtime (not build time) because SteamCMD
# segfaults under QEMU when cross-building on ARM, and this keeps the image
# small while always pulling the latest version.
if [ ! -f "${SERVER_DIR}/steamapps/appmanifest_4019830.acf" ]; then
    echo "[DragonWilds] First run — installing server files (this will take a few minutes)..."
    steamcmd +force_install_dir "${SERVER_DIR}" \
             +login anonymous \
             +app_update 4019830 validate \
             +quit
    echo "[DragonWilds] Install complete."
elif [ "${AUTO_UPDATE}" = "true" ]; then
    echo "[DragonWilds] Checking for server updates..."
    steamcmd +force_install_dir "${SERVER_DIR}" \
             +login anonymous \
             +app_update 4019830 \
             +quit
    echo "[DragonWilds] Update check complete."
fi

# --- Generate DedicatedServer.ini from environment variables ---
mkdir -p "${CONFIG_DIR}"

if [ ! -f "${CONFIG_FILE}" ] || [ "${FORCE_CONFIG}" = "true" ]; then
    echo "[DragonWilds] Writing DedicatedServer.ini..."
    cat > "${CONFIG_FILE}" <<EOF
[DedicatedServer]
OwnerID=${OWNER_ID}
ServerName=${SERVER_NAME}
DefaultWorldName=${DEFAULT_WORLD_NAME}
AdminPassword=${ADMIN_PASSWORD}
WorldPassword=${WORLD_PASSWORD}
EOF
    echo "[DragonWilds] Config written to ${CONFIG_FILE}"
else
    echo "[DragonWilds] Existing DedicatedServer.ini found, skipping generation (set FORCE_CONFIG=true to overwrite)."
fi

echo "[DragonWilds] --- Configuration ---"
cat "${CONFIG_FILE}"
echo "[DragonWilds] --------------------"

# --- Find and launch the server binary ---
SERVER_BIN="${SERVER_DIR}/RSDragonwildsServer.sh"

if [ ! -f "${SERVER_BIN}" ]; then
    # Fallback: search for common Unreal dedicated server binary names
    SERVER_BIN=$(find "${SERVER_DIR}" -maxdepth 2 -name "*Server.sh" -type f | head -n 1)
fi

if [ -z "${SERVER_BIN}" ] || [ ! -f "${SERVER_BIN}" ]; then
    echo "[DragonWilds] ERROR: Could not find server binary. Contents of ${SERVER_DIR}:"
    ls -la "${SERVER_DIR}"
    exit 1
fi

chmod +x "${SERVER_BIN}"

echo "[DragonWilds] Starting server on port ${SERVER_PORT}..."
exec "${SERVER_BIN}" -log -port="${SERVER_PORT}" "$@"
