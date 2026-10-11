#!/usr/bin/env bash
# Build and install Anisette-Server-26 as a local Docker container.
# Does not overwrite an existing container or claim an occupied port.
set -Eeuo pipefail

cd "$(dirname "$0")"

IMAGE="anisette-server-26:latest"
NAME="anisette-server-26"
HOST_PORT="${HOST_PORT:-6970}"
VOLUME="${ANISETTE_VOLUME:-anisette-server-26-data}"
CLIENT_INFO="${ANISETTE_CLIENT_INFO:-<Mac14,2> <macOS;15.7.5;24G624> <com.apple.AuthKit/1 (com.apple.akd/1.0)>}"

if ! command -v docker >/dev/null 2>&1; then
    echo "Docker is required." >&2
    exit 1
fi

DOCKER=(docker)
if ! docker info >/dev/null 2>&1; then
    DOCKER=(sudo docker)
fi
"${DOCKER[@]}" info >/dev/null

if "${DOCKER[@]}" container inspect "$NAME" >/dev/null 2>&1; then
    echo "Container '$NAME' already exists. Refusing to replace it." >&2
    exit 1
fi

if ! [[ "$HOST_PORT" =~ ^[0-9]+$ ]] || (( HOST_PORT < 1 || HOST_PORT > 65535 )); then
    echo "HOST_PORT must be between 1 and 65535." >&2
    exit 1
fi

echo "Building $IMAGE ..."
"${DOCKER[@]}" build -t "$IMAGE" .

echo "Preparing volume $VOLUME ..."
"${DOCKER[@]}" volume create "$VOLUME" >/dev/null

echo "Starting $NAME at 127.0.0.1:$HOST_PORT ..."
"${DOCKER[@]}" run -d \
    --restart unless-stopped \
    --name "$NAME" \
    -p "127.0.0.1:$HOST_PORT:6969" \
    -e "ANISETTE_CLIENT_INFO=$CLIENT_INFO" \
    -v "$VOLUME:/home/Alcoholic/.config/anisette-v3/lib/" \
    "$IMAGE"

echo "Waiting for server response ..."
ok=0
for i in $(seq 1 30); do
    if curl -fsS --max-time 3 "http://127.0.0.1:$HOST_PORT" >/dev/null 2>&1; then
        ok=1
        break
    fi
    sleep 2
done

if (( ok == 1 )); then
    echo "Anisette is responding."
    echo "AltServer endpoint: http://127.0.0.1:$HOST_PORT"
else
    echo "Server did not respond. Inspect: ${DOCKER[*]} logs $NAME" >&2
    exit 1
fi
