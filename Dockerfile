FROM steamcmd/steamcmd:ubuntu-24

# Install minimal dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends lib32gcc-s1 ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Create a non-root user to run the server
RUN useradd -m -s /bin/bash dragonwilds

# Set up directories
ENV SERVER_DIR="/home/dragonwilds/server"
ENV CONFIG_DIR="/home/dragonwilds/server/RSDragonwilds/Saved/Config/Linux"
ENV SAVEGAMES_DIR="/home/dragonwilds/server/RSDragonwilds/Saved/Savegames"
ENV LOGS_DIR="/home/dragonwilds/server/RSDragonwilds/Saved/Logs"

RUN mkdir -p "${SERVER_DIR}" "${SAVEGAMES_DIR}" "${LOGS_DIR}" && \
    chown -R dragonwilds:dragonwilds /home/dragonwilds

# Point SteamCMD to the non-root user's home so it doesn't try /root
ENV HOME="/home/dragonwilds"

# Copy entrypoint
COPY --chown=dragonwilds:dragonwilds entrypoint.sh /home/dragonwilds/entrypoint.sh
RUN chmod +x /home/dragonwilds/entrypoint.sh

# Default environment variables for server config (no secrets baked in)
ENV SERVER_NAME="DragonWilds Server" \
    OWNER_ID="" \
    DEFAULT_WORLD_NAME="" \
    SERVER_PORT=7777 \
    AUTO_UPDATE=true

# Expose the game port (UDP)
EXPOSE 7777/udp

# Persist server files, save games, config, and logs
VOLUME ["${SERVER_DIR}", "${SAVEGAMES_DIR}", "${CONFIG_DIR}", "${LOGS_DIR}"]

# Drop to non-root for runtime
USER dragonwilds
WORKDIR ${SERVER_DIR}

ENTRYPOINT ["/home/dragonwilds/entrypoint.sh"]
