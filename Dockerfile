# Multistage build; compile with DUB inside Docker
FROM debian:stable-20250520-slim AS builder
RUN apt-get update && apt-get install --no-install-recommends -y ca-certificates ldc git clang dub libz-dev libssl-dev libplist-dev libplist-2.0-4 \
 && apt-get clean && rm -rf /var/lib/apt/lists/*
WORKDIR /opt/
COPY . .
RUN DC=ldc2 dub build -c "static" --build-mode allAtOnce -b release --compiler=ldc2

FROM debian:stable-slim
RUN apt-get update && apt-get install --no-install-recommends -y ca-certificates curl libplist-dev libplist-2.0-4 \
 && apt-get clean && rm -rf /var/lib/apt/lists/*
WORKDIR /opt/
COPY --from=builder /opt/anisette-server-26 /opt/anisette-server-26
RUN mkdir -p /opt/anisette-v3/provisioning
RUN useradd -ms /bin/bash Alcoholic \
 && mkdir -p /home/Alcoholic/.config/anisette-v3/lib/ \
 && chown -R Alcoholic /home/Alcoholic/ /opt/ \
 && chmod -R +wx /home/Alcoholic/ /opt/
USER Alcoholic
EXPOSE 6969
ENTRYPOINT ["/opt/anisette-server-26"]
