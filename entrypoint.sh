#!/bin/bash
set -e

SERVER_DIR="/home/dragonwilds/server"
CONFIG_DIR="${SERVER_DIR}/RSDragonwilds/Saved/Config/LinuxServer"
CONFIG_FILE="${CONFIG_DIR}/DedicatedServer.ini"

ADMIN_PASSWORD="${ADMIN_PASSWORD:-changeme}"
WORLD_PASSWORD="${WORLD_PASSWORD:-}"
MAX_PLAYERS="${MAX_PLAYERS:-6}"
ADMINISTRATOR_LIST="${ADMINISTRATOR_LIST:-}"

# --- Install / update server files via SteamCMD ---
steamcmd_run() {
    local attempt=1
    local max_attempts=3
    while [ $attempt -le $max_attempts ]; do
        echo "[DragonWilds] SteamCMD attempt ${attempt}/${max_attempts}..."
        if steamcmd +force_install_dir "${SERVER_DIR}" \
                    +login anonymous \
                    +app_update 4019830 validate \
                    +quit; then
            return 0
        fi
        echo "[DragonWilds] SteamCMD failed (attempt ${attempt}/${max_attempts})."
        rm -rf "${SERVER_DIR}/steamapps/downloading"
        rm -rf "${SERVER_DIR}/steamapps/temp"
        rm -f "${SERVER_DIR}/steamapps/appmanifest_4019830.acf"
        echo "[DragonWilds] Cleared download cache. Retrying..."
        attempt=$((attempt + 1))
    done
    echo "[DragonWilds] ERROR: SteamCMD failed after ${max_attempts} attempts."
    return 1
}

if [ ! -f "${SERVER_DIR}/steamapps/appmanifest_4019830.acf" ]; then
    echo "[DragonWilds] First run — installing server files (this will take a few minutes)..."
    steamcmd_run
    echo "[DragonWilds] Install complete."
elif [ "${AUTO_UPDATE}" = "true" ]; then
    echo "[DragonWilds] Checking for server updates..."
    steamcmd_run
    echo "[DragonWilds] Update check complete."
else
    echo "[DragonWilds] Skipping update check (AUTO_UPDATE=false)."
fi

# --- Write DedicatedServer.ini ---
# Preserve ServerGuid if the game already generated one
mkdir -p "${CONFIG_DIR}"
EXISTING_GUID=""
if [ -f "${CONFIG_FILE}" ]; then
    EXISTING_GUID=$(grep -oP 'ServerGuid=\K.*' "${CONFIG_FILE}" 2>/dev/null || true)
fi

echo "[DragonWilds] Writing ${CONFIG_FILE}..."
cat > "${CONFIG_FILE}" <<EOF
[/Script/Dominion.DedicatedServerSettings]
OwnerId=${OWNER_ID}
ServerName=${SERVER_NAME}
DefaultWorldName=${DEFAULT_WORLD_NAME}
AdminPassword=${ADMIN_PASSWORD}
WorldPassword=${WORLD_PASSWORD}
MaxPlayers=${MAX_PLAYERS}
AdministratorList=(${ADMINISTRATOR_LIST})
EOF

# Re-add ServerGuid if it existed
if [ -n "${EXISTING_GUID}" ]; then
    echo "ServerGuid=${EXISTING_GUID}" >> "${CONFIG_FILE}"
fi

echo "[DragonWilds] Config contents:"
cat "${CONFIG_FILE}"

# --- Launch the server ---
SERVER_BIN="${SERVER_DIR}/RSDragonwildsServer.sh"

if [ ! -f "${SERVER_BIN}" ]; then
    SERVER_BIN=$(find "${SERVER_DIR}" -maxdepth 2 -name "*Server.sh" -type f | head -n 1)
fi

if [ -z "${SERVER_BIN}" ] || [ ! -f "${SERVER_BIN}" ]; then
    echo "[DragonWilds] ERROR: Could not find server binary. Contents of ${SERVER_DIR}:"
    ls -la "${SERVER_DIR}"
    exit 1
fi

chmod +x "${SERVER_BIN}"
chown -R dragonwilds:dragonwilds "${SERVER_DIR}/RSDragonwilds/Saved"
echo "[DragonWilds] Starting server on port ${SERVER_PORT}..."
exec gosu dragonwilds "${SERVER_BIN}" -log -port="${SERVER_PORT}" "$@"
