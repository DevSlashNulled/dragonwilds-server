# DragonWilds Dedicated Server

Docker container for hosting a [RuneScape: DragonWilds](https://dragonwilds.runescape.com/) dedicated server using SteamCMD.

## Features

- Automatic server installation via SteamCMD (App 4019830)
- Auto-updates on every container start
- Configurable via environment variables
- Persistent server files, save games, and logs
- Unraid Community Applications template included

## Quick Start

### Docker Compose

```bash
git clone https://github.com/devslashnulled/dragonwilds-server.git
cd dragonwilds-server
```

Edit `docker-compose.yml` with your settings, then:

```bash
docker compose up -d
```

### Docker Run

```bash
docker run -d \
  --name dragonwilds \
  -p 7777:7777/udp \
  -e SERVER_NAME="My Server" \
  -e OWNER_ID="your-player-id" \
  -e ADMIN_PASSWORD="your-password" \
  -v /path/to/serverfiles:/home/dragonwilds/server \
  -v /path/to/savegames:/home/dragonwilds/server/RSDragonwilds/Saved/SaveGames \
  -v /path/to/logs:/home/dragonwilds/server/RSDragonwilds/Saved/Logs \
  devslashnulled/dragonwilds-server:latest
```

### Unraid

Copy the template to your Unraid flash drive:
```bash
wget -O /boot/config/plugins/dockerMan/templates-user/my-dragonwilds-server.xml \
  https://raw.githubusercontent.com/devslashnulled/dragonwilds-server/main/templates/dragonwilds-server.xml
```

Then go to **Docker > Add Container > Template dropdown** and select **dragonwilds-server**.

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `SERVER_NAME` | `DragonWilds Server` | Name shown in the server browser |
| `OWNER_ID` | *(empty)* | Your Player ID from the in-game Settings menu |
| `ADMIN_PASSWORD` | `changeme` | Server administration password |
| `WORLD_PASSWORD` | *(empty)* | Password to join (empty = no password) |
| `DEFAULT_WORLD_NAME` | *(empty)* | Specific world save to load (empty = latest) |
| `SERVER_PORT` | `7777` | Game port (change for multiple servers) |
| `AUTO_UPDATE` | `true` | Update server via SteamCMD on each start |

Environment variables are written to `DedicatedServer.ini` on every startup. To change settings, update the env vars and restart.

## Ports

| Port | Protocol | Description |
|---|---|---|
| `7777` | UDP | Game client connections |

## Volumes

| Container Path | Description |
|---|---|
| `/home/dragonwilds/server` | Server installation files (4GB+, must persist) |
| `.../RSDragonwilds/Saved/SaveGames` | World save data |
| `.../RSDragonwilds/Saved/Logs` | Server logs |

## System Requirements

- **Platform:** Linux amd64 only
- **RAM:** 2 GB base + 1 GB per player (8 GB for max 6 players)
- **Network:** Port 7777/UDP forwarded on your router

## Logs

```bash
docker logs -f dragonwilds
```

Server log file is also available in the logs volume at `RSDragonwilds.log`.
