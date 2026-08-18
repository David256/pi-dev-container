FROM oven/bun:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/home/bun
ENV NVM_DIR=/home/bun/.nvm
ENV BUN_INSTALL=/home/bun/.bun

RUN apt-get update && apt-get install -y --no-install-recommends \
    ripgrep \
    wget curl \
    zip unzip \
    git \
    python3 python3-pip python3-venv \
    ca-certificates sudo vim \
    netcat-openbsd iputils-ping \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# Config the user
# ------------------------------------------------------------

RUN echo "bun ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/bun \
    && chmod 0440 /etc/sudoers.d/bun

# ------------------------------------------------------------
# Install bun
# ------------------------------------------------------------

RUN bun add -g --ignore-scripts @earendil-works/pi-coding-agent

# ------------------------------------------------------------
# Directories
# ------------------------------------------------------------

RUN mkdir -p \
    /home/bun/source \
    && chown -R bun:bun /home/bun

# ------------------------------------------------------------

USER bun
WORKDIR /home/bun/source

# ------------------------------------------------------------
# Shell configuration
# ------------------------------------------------------------

RUN cat >> /home/bun/.bashrc <<'EOF'
PS1="\[\e[30;107;1m\] pi \[\e[0m\]:\[\e[96;3m\]\w\[\e[0;36m\]\$\[\e[0m\] "
EOF

CMD [ "pi" ]
