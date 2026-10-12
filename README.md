# Anisette-Server-26

This is a minimal update of [Dadoum's anisette-v3-server](https://github.com/Dadoum/anisette-v3-server) to restore compatibility with the Apple authentication flow used by [AltServer-Linux](https://github.com/NyaMisty/AltServer-Linux) and [SideStore](https://github.com/SideStore/SideStore). The investigation was aided by [isideload](https://github.com/nab138/isideload) (Rust) and OpenAI's ChatGPT (AI-assisted debugging and documentation). It is fully functional with with [AltServer-Linux-26](https://github.com/hroy123/AltServer-Linux-26) and was developed and tested on an ARM64 Orange Pi. 

**Credit:** This project is based on Dadoum's work, not a new implementation. Most upstream code is unchanged.

## September 2026 Apple authentication changes

Apple's September 2026 authentication changes required small updates to Anisette:

- GrandSlam HTTP 503 responses associated with the older Xcode client identity.
- Updated Anisette client identity and device-initialization handling.
- Updated Apple serial-number header fallback.

These issues were addressed through minimal changes to [Dadoum's anisette-v3-server](https://github.com/Dadoum/anisette-v3-server). Separate AltServer authentication fixes are documented in [AltServer-Linux-26](https://github.com/hroy123/AltServer-Linux-26).

**Anisette-Server-26** was tested with [AltServer-Linux-26](https://github.com/hroy123/AltServer-Linux-26) on an ARM64 Orange Pi. Anisette ran in Docker, and an AltStore app refresh completed successfully.

## Install on Linux with Docker

Requires Docker, Git, and an internet connection. Build locally; no D compiler is required on the host.

```bash
git clone https://github.com/hroy123/Anisette-server-26.git
cd Anisette-server-26
chmod +x install-docker.sh
./install-docker.sh
```

By default, the installer builds `anisette-server-26:latest`, names the container `anisette-server-26`, and maps **port 6970** (`127.0.0.1:6970`) to **port 6969 inside the Docker container**, where Anisette listens. AltServer running directly on the same Orange Pi connects to `http://127.0.0.1:6970`.

**Automatic startup:** The installer uses Docker's `--restart unless-stopped` policy. Anisette will start automatically after a reboot, provided the Docker service starts at boot. If you manually stop the container, it will stay stopped until you start it again.

For a different host port:

```bash
HOST_PORT=6971 ./install-docker.sh
```

The Apple client identity can be customized using the `ANISETTE_CLIENT_INFO` environment variable; the installer already supplies the tested default.

For AltServer running on the same machine:

```bash
export ALTSERVER_ANISETTE_SERVER=http://127.0.0.1:6970
```

Check the server using `curl -fsS http://127.0.0.1:6970 >/dev/null`, or see `docker logs anisette-server-26`. Avoid publishing full Anisette responses or logs because they contain authentication-related values.

**First sign-in:** Apple may request a two-factor authentication (2FA) verification code when you first sign in through AltStore to refresh or sideload an app. Subsequent refreshes normally do not require another code, although Apple may request verification again if the session expires or the device identity changes.

## Acknowledgments

- [Dadoum / anisette-v3-server](https://github.com/Dadoum/anisette-v3-server): original server and Docker/DUB implementation.
- [Dadoum / Provision](https://github.com/Dadoum/Provision): underlying provisioning dependency.
- [SideStore](https://github.com/SideStore/SideStore) and [AltServer-Linux](https://github.com/NyaMisty/AltServer-Linux): ecosystem and client integration.
- [nab138 / isideload](https://github.com/nab138/isideload): Rust reference implementation used to investigate contemporary Apple authentication behavior.
- **OpenAI ChatGPT:** AI-assisted source comparison, debugging, scripting, and documentation. Changes and deployment were tested by the maintainer.

Upstream authors retain credit for their work and their respective licenses. This is an independent compatibility update, not an official Apple, SideStore, or Dadoum release.
