FROM debian:13

ARG USERNAME=developer
ARG UID=1000
ARG GID=1000
ARG NODE_VERSION=22

ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/home/${USERNAME}
ENV NVM_DIR=/home/${USERNAME}/.nvm
ENV BUN_INSTALL=/home/${USERNAME}/.bun

# ------------------------------------------------------------
# General development tools
# ------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    bash-completion \
    build-essential \
    ca-certificates \
    cmake \
    ripgrep \
    curl \
    file \
    g++ \
    gcc \
    git \
    gnupg \
    jq \
    less \
    make \
    nano \
    neovim \
    openssh-client \
    pkg-config \
    python3 \
    python3-pip \
    python3-venv \
    rsync \
    sudo \
    tar \
    tmux \
    unzip \
    vim \
    wget \
    zip \
    zsh \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# User
# ------------------------------------------------------------
RUN groupadd --gid ${GID} ${USERNAME} \
    && useradd \
    --uid ${UID} \
    --gid ${GID} \
    --create-home \
    --shell /bin/bash \
    ${USERNAME} \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME}

# Persistent directories
RUN mkdir -p \
    /home/${USERNAME}/.local \
    /home/${USERNAME}/source \
    /home/${USERNAME}/.nvm \
    && chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

USER ${USERNAME}
WORKDIR /home/${USERNAME}

# ------------------------------------------------------------
# NVM
# ------------------------------------------------------------
RUN curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.5/install.sh \
    | bash \
    && . "${NVM_DIR}/nvm.sh" \
    && nvm install ${NODE_VERSION} \
    && nvm alias default ${NODE_VERSION} \
    && nvm use default \
    && npm install --global npm@latest

# ------------------------------------------------------------
# Shell configuration
# ------------------------------------------------------------
RUN cat >> /home/${USERNAME}/.bashrc <<'EOF'

export NVM_DIR="$HOME/.nvm"

[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

export PATH="$HOME/.local/bin:$PATH"

# Convenient directories
export SOURCE_DIR="$HOME/source"
export LOCAL_DIR="$HOME/.local"

cd "$SOURCE_DIR" 2>/dev/null || true

if [ ! -z "$PROJECT" ];
then
    PS1="\[\e[30;107;1m\] ${PROJECT} \[\e[0m\]:\[\e[96;3m\]\w\[\e[0;36m\]\$\[\e[0m\] "
fi

EOF

# ---

# ------------------------------------------------------------
# Bun
# ------------------------------------------------------------

RUN mkdir -p $BUN_INSTALL \
    && curl -fsSL https://bun.com/install | bash
ENV PATH="$BUN_INSTALL/bin:$PATH"

# ------------------------------------------------------------
# Install pi.dev
# ------------------------------------------------------------

RUN "$BUN_INSTALL/bin/bun" add -g @earendil-works/pi-coding-agent

# ------------------------------------------------------------
# Entrypoint
# ------------------------------------------------------------
USER root

RUN cat > /usr/local/bin/support-entrypoint <<'EOF'
#!/bin/bash
set -e

export HOME=/home/developer
export NVM_DIR="$HOME/.nvm"

[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

export PATH="$HOME/.local/bin:$PATH"

exec "$@"
EOF

# ---

RUN chmod +x /usr/local/bin/support-entrypoint \
    && chown ${USERNAME}:${USERNAME} /usr/local/bin/support-entrypoint

USER ${USERNAME}

WORKDIR /home/${USERNAME}/source

ENTRYPOINT ["/usr/local/bin/support-entrypoint"]
CMD ["pi"]

