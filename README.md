# Anisette-Server-26

A minimal update of [Dadoum's anisette-v3-server](https://github.com/Dadoum/anisette-v3-server) to restore compatibility with the Apple authentication flow used by [AltServer-Linux](https://github.com/NyaMisty/AltServer-Linux) and [SideStore](https://github.com/SideStore/SideStore). The investigation was aided by [isideload](https://github.com/nab138/isideload) (Rust) and OpenAI's ChatGPT (AI-assisted debugging and documentation).

**Credit:** This project is based on Dadoum's work, not a new implementation. Most upstream code is unchanged.

## September 2026 Apple authentication changes

Apple's September 2026 authentication changes caused several issues:

- HTTP 503 responses from GrandSlam with the older Xcode client identity.
- HTTP 429 responses when AltServer reused HTTP connections.
- Failure to decrypt Apple's SPD authentication data using the older SRP key derivation.
- Anisette device-identity and serial-header compatibility issues.

These issues were resolved with small, targeted updates to [Dadoum's anisette-v3-server](https://github.com/Dadoum/anisette-v3-server) and the separate AltServer/AltSign code; the HTTP 429 and SPD fixes are **not** part of this Anisette repository.

**Anisette-Server-26** was modified and tested with [AltServer-Linux-26](https://github.com/hroy123/AltServer-Linux-26) on an ARM64 Orange Pi, using Docker containers for both services. App refresh was successfully verified.

## Install on Linux with Docker

Requires Docker, Git, and an internet connection. Build locally; no D compiler is required on the host.

```bash
git clone https://github.com/hroy123/Anisette-server-26.git
cd Anisette-server-26
chmod +x install-docker.sh
./install-docker.sh
```

By default, the installer builds `anisette-server-26:latest`, names the container `anisette-server-26`, and maps **port 6970 on the Orange Pi** (`127.0.0.1:6970`) to **port 6969 inside the Docker container**, where Anisette listens. AltServer running directly on the Orange Pi connects to `http://127.0.0.1:6970`; the `127.0.0.1` binding prevents access from other machines. It uses Docker volume `anisette-server-26-data` to retain its Anisette library data. The script refuses to replace existing containers or take an occupied port silently.

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

**First use:** When refreshing or sideloading an app through AltStore for the first time, Apple may ask for a two-factor authentication (2FA) verification code. Normally, once the sign-in is verified, subsequent refreshes do not require another code. Apple may ask again if the authentication session expires, account security changes, or Anisette is reprovisioned with a new device identity.

### Existing deployments

**Multiple installations:** Docker images can coexist without interfering with one another, including large temporary build images. To run multiple Anisette containers simultaneously, use different container names, host ports (for example, 6970 and 6971), and preferably separate data volumes. This installer uses the fixed name `anisette-server-26`, so a second installation requires adjusting the name in the script. If a container is recreated without preserving its device identity, Apple may request two-factor authentication again.

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
