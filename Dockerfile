# Etapa 1: Construir yamlfmt
FROM golang:1 AS go-builder

# Instalar yamlfmt
WORKDIR /yamlfmt
RUN go install github.com/google/yamlfmt/cmd/yamlfmt@latest && \
  strip $(which yamlfmt) && \
  yamlfmt --version

# Etapa 2: Configurar ambiente de desenvolvimento
FROM node:20-buster-slim

# Variáveis de ambiente
ENV USER=solana
ENV HOME=/home/${USER}
ENV CARGO_HOME=${HOME}/.cargo
ENV RUSTUP_HOME=${HOME}/.rustup
ENV SOLANA_VERSION=1.18.26
ENV ANCHOR_VERSION=0.30.1
ENV PATH=${HOME}/.local/share/solana/install/releases/${SOLANA_VERSION}/bin:${CARGO_HOME}/bin:${PATH}

# Instalar dependências do sistema
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  bash-completion \
  build-essential \
  ca-certificates \
  curl \
  git \
  gnupg2 \
  libssl-dev \
  libudev-dev \
  llvm \
  pkg-config \
  protobuf-compiler \
  python3 \
  sudo \
  wget \
  fonts-powerline && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  useradd --create-home --shell /bin/bash ${USER} && \
  usermod -aG sudo ${USER} && \
  echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Alternar para o usuário solana
USER ${USER}
WORKDIR ${HOME}

# Instalar Oh My Bash, configurar tema powerline e plugins de autocomplete, instalar Rust e Solana
RUN bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" --unattended && \
  sed -i 's/OSH_THEME=.*/OSH_THEME="powerline"/' ${HOME}/.bashrc && \
  sed -i 's/plugins=.*/plugins=(git docker)/' ${HOME}/.bashrc && \
  curl https://sh.rustup.rs -sSf | sh -s -- -y && \
  . ${CARGO_HOME}/env && \
  rustup default stable && \
  rustc --version && \
  cargo --version && \
  curl -sSfL https://release.solana.com/v${SOLANA_VERSION}/install | sh && \
  solana --version && \
  cargo install --git https://github.com/coral-xyz/anchor avm --locked && \
  avm install ${ANCHOR_VERSION} && \
  avm use ${ANCHOR_VERSION} && \
  anchor --version

COPY --from=go-builder /go/bin/yamlfmt /usr/local/bin/yamlfmt

# Configurar diretório de trabalho
WORKDIR ${HOME}/workspace

# Expor porta para desenvolvimento
EXPOSE 8899

# Comando padrão
CMD ["bash"]
