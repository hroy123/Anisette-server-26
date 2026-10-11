# Anisette-Server-26

A minimal update of [Dadoum's anisette-v3-server](https://github.com/Dadoum/anisette-v3-server) to restore compatibility with the Apple authentication flow used by [AltServer-Linux](https://github.com/NyaMisty/AltServer-Linux) and [SideStore](https://github.com/SideStore/SideStore). The investigation was aided by [isideload](https://github.com/nab138/isideload) (Rust) and OpenAI's ChatGPT (AI-assisted debugging and documentation).

**Credit:** This project is based on Dadoum's work, not a new implementation. Most upstream code is unchanged.

## Changes (September–October 2026)

Apple authentication started rejecting the previously used client identity in some GrandSlam requests (HTTP 503). This version makes the `X-MMe-Client-Info` identity configurable with `ANISETTE_CLIENT_INFO`, updates the fallback identity, and retains the r2 device-initialization fix so a new device record is populated before the identity override is applied. The Apple serial-number header fallback was also changed to `C0FFFFFFFFFFFF`.

The DUB executable and Docker image/container are standardized as `anisette-server-26`. The server continues listening on **6969** inside the container.

These are deliberately small changes to Dadoum's server. **AltServer-Linux's separate HTTP 429, SRP, and SPD fixes are not part of this repository.** See the AltServer-Linux project for those changes.

Tested on an ARM64 Orange Pi with Docker and AltServer-Linux using a successful app refresh in October 2026. Apple may change its authentication requirements again.

## Install on Linux with Docker

Requires Docker, Git, and an internet connection. Build locally; no D compiler is required on the host.

```bash
git clone https://github.com/hroy123/Anisette-server-26.git
cd Anisette-server-26
chmod +x install-docker.sh
./install-docker.sh
```

By default, the installer builds `anisette-server-26:latest`, names the container `anisette-server-26`, and exposes it only to the host at **127.0.0.1:6970** (container port 6969). It uses Docker volume `anisette-server-26-data` to retain its Anisette library data. The script refuses to replace existing containers or take an occupied port silently.

For a different host port:

```bash
HOST_PORT=6971 ./install-docker.sh
```

To override the Apple client identity (the configuration tested in October 2026):

```bash
ANISETTE_CLIENT_INFO='<Mac14,2> <macOS;15.7.5;24G624> <com.apple.AuthKit/1 (com.apple.akd/1.0)>' ./install-docker.sh
```

For AltServer running on the same machine:

```bash
export ALTSERVER_ANISETTE_SERVER=http://127.0.0.1:6970
```

Check the server using `curl -fsS http://127.0.0.1:6970 >/dev/null`, or see `docker logs anisette-server-26`. Avoid publishing full Anisette responses or logs because they contain authentication-related values.

### Existing deployments

**Do not run the installer over an existing service without planning the migration.** It will refuse to reuse an occupied port or container name. Docker volumes need careful handling: the default mount preserves the `lib` subdirectory, but some device identity files can exist outside it. Recreating a container may generate a new device identity and require another Apple verification. Back up your data first and stop the old container only when ready.

To inspect existing containers:

```bash
docker ps -a
docker volume ls
```

## Build directly (without Docker)

With the D compiler, DUB, and development libraries installed:

```bash
DC=ldc2 dub build -c static --build-mode allAtOnce -b release --compiler=ldc2
```

The resulting executable is `anisette-server-26`.

## Acknowledgments

- [Dadoum / anisette-v3-server](https://github.com/Dadoum/anisette-v3-server): original server and Docker/DUB implementation.
- [Dadoum / Provision](https://github.com/Dadoum/Provision): underlying provisioning dependency.
- [SideStore](https://github.com/SideStore/SideStore) and [AltServer-Linux](https://github.com/NyaMisty/AltServer-Linux): ecosystem and client integration.
- [nab138 / isideload](https://github.com/nab138/isideload): Rust reference implementation used to investigate contemporary Apple authentication behavior.
- **OpenAI ChatGPT:** AI-assisted source comparison, debugging, scripting, and documentation. Changes and deployment were tested by the maintainer.

Upstream authors retain credit for their work and their respective licenses. This is an independent compatibility update, not an official Apple, SideStore, or Dadoum release.
