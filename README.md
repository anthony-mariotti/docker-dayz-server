# DayZ Docker Image

Docker support for DayZ server. Currently this container only supports vanilla (no mods).

## Work in progress

- [ ] Mod Support
- [ ] Graceful Shutdown
- [ ] Health Check
- [ ] Monitoring
- [ ] Custom Missions
- [ ] Custom Configurations
- [x] Environment Variable Configuration
- [x] Vanilla Mission Download (Missing Game License)

## Configuration / Environment

See: [ENVIRONMENT](ENVIRONMENT.md)

## Development

Let's get started by setting up your development environment and the requirements for building the container.

### Requirements

- Docker
- Steam Account
- Git Bash (Windows)

### Building

There is a provided `./build.sh` script that will build the image locally with the tag `dayz:dev`.

If you would like to customize the tag you can run the following command against the build script.

```bash
./build.sh [IMAGE_NAME] [VERSION_TAG]
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