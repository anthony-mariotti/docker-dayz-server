# DayZ Docker Image

Docker support for DayZ server. Currently this container only supports vanilla (no mods).

## Work in progress

- [ ] ghcr.io publish
- [ ] hub.docker.com publish
- [ ] Versioning Methodology
- [ ] DayZ Mod Support
- [ ] DayZ Monitoring
- [ ] DayZ RCON CLI
- [ ] DayZ Custom Missions
- [ ] DayZ Custom Configurations
- [x] DayZ Graceful Shutdown
	- [ ] DayZ takes greater than `10s` to gracefully shutdown
- [x] DayZ Health Check
- [x] DayZ Environment Variable Configuration
- [x] DayZ Vanilla Mission Download (Missing Game License)

## Configuration / Environment


> [!NOTE]
> At the moment, `stop_grace_period` should be set greater than `15s`. Vanilla DayZ server takes around 15-40 seconds to save and clear resources which is outside the default docker grace period of 10 seconds before it kills the container.

See: [Environment Variables](ENVIRONMENT.md)

See: [Example Docker Compose](docker-compose.template.yml)

## Development

Let's get started by setting up your development environment and the requirements for building the container.

### Requirements

- Docker
- Steam Account
- Git Bash (Windows)

#### System Requirements (Minimum)

CPU

- Intel Dual-Core 2.4 GHz
- AMD Dual-Core Athlon 2.5 GHz

Memory

- 6 GB

Storage

- 5 GB space on the drive 

See: [Server Requirements - DayZ](https://community.bistudio.com/wiki/DayZ:Server_Requirements)

### Building

There is a provided `./build.sh` script that will build the image locally with the tag `dayz:dev`.

If you would like to customize the tag you can run the following command against the build script.

```bash
./build.sh [IMAGE_NAME] [DOCKERFILE]
```

### Running

Provided is a `docker-compose.template.yml` file as a template that you can copy over to `docker-compose.yml` so you can run within this repository without separating directories.

Other template configuration files are also provided witin this repo to also help with development.

The template docker compose file contains secrets for `steam_password`, `server_password`, and `admin_password`. These files are ignored by git to keep credentials secure. Creating these files within the directory of the project are needed in order to start the container.

Alternatively you can provide these three items via environment variables to the docker compose file.

```bash
docker compose up -d
```

```bash
docker compose down
```

When making changes to the containers file system, make sure to consider existing volume mounts. 