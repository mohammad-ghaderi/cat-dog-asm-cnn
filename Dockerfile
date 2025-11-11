FROM debian:bookworm-slim

# Install NASM and linking tools
RUN apt-get update && \
    apt-get install -y  --no-install-recommends \
    nasm build-essential gdb && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /mnt/project
CMD ["tail", "-f", "/dev/null"]