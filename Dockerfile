FROM steamcmd/steamcmd:ubuntu-24

# Install minimal dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends lib32gcc-s1 ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Create a non-root user to run the server
RUN useradd -m -s /bin/bash dragonwilds
USER dragonwilds

# Set up directories
ENV SERVER_DIR="/home/dragonwilds/server"
ENV CONFIG_DIR="/home/dragonwilds/server/RSDragonwilds/Saved/Config/Linux"
ENV SAVEGAMES_DIR="/home/dragonwilds/server/RSDragonwilds/Saved/Savegames"
ENV LOGS_DIR="/home/dragonwilds/server/RSDragonwilds/Saved/Logs"

RUN mkdir -p "${SERVER_DIR}" "${SAVEGAMES_DIR}" "${LOGS_DIR}"

# Install/update the dedicated server via SteamCMD
RUN steamcmd +force_install_dir "${SERVER_DIR}" \
             +login anonymous \
             +app_update 4019830 validate \
             +quit

# Copy entrypoint
COPY --chown=dragonwilds:dragonwilds entrypoint.sh /home/dragonwilds/entrypoint.sh
RUN chmod +x /home/dragonwilds/entrypoint.sh

# Default environment variables for server config
ENV SERVER_NAME="DragonWilds Server" \
    OWNER_ID="" \
    ADMIN_PASSWORD="changeme" \
    WORLD_PASSWORD="" \
    DEFAULT_WORLD_NAME="" \
    SERVER_PORT=7777 \
    AUTO_UPDATE=true

# Expose the game port (UDP)
EXPOSE 7777/udp

# Persist save games, config, and logs
VOLUME ["${SAVEGAMES_DIR}", "${CONFIG_DIR}", "${LOGS_DIR}"]

WORKDIR ${SERVER_DIR}

ENTRYPOINT ["/home/dragonwilds/entrypoint.sh"]
