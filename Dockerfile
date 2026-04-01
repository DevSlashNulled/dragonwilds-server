FROM steamcmd/steamcmd:ubuntu-24

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates gosu && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash dragonwilds

ENV SERVER_DIR="/home/dragonwilds/server"
RUN mkdir -p "${SERVER_DIR}" && chown dragonwilds:dragonwilds "${SERVER_DIR}"

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV SERVER_NAME="DragonWilds Server" \
    OWNER_ID="" \
    DEFAULT_WORLD_NAME="" \
    SERVER_PORT=7777 \
    AUTO_UPDATE=true

EXPOSE 7777/udp

WORKDIR ${SERVER_DIR}
ENTRYPOINT ["/entrypoint.sh"]
