# Usar a imagem oficial do Ubuntu 20.04 como base para a arquitetura amd64
FROM --platform=linux/amd64 ubuntu:22.04

# Definir o fuso horário para evitar prompts durante a instalação
ENV TZ=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Atualizar o sistema e instalar dependências necessárias
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    libssl-dev \
    pkg-config \
    python3 \
    sudo \
    ca-certificates \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Criar usuário 'solana' com permissões sudo
RUN useradd --create-home -s /bin/bash solana && \
    usermod -aG sudo solana && \
    echo 'solana ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Alternar para o usuário 'solana'
USER solana
WORKDIR /home/solana

# Instalar Rust e Cargo
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/home/solana/.cargo/bin:${PATH}"

# Instalar Node.js 22
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash - && \
    sudo apt-get install -y nodejs

# Verificar instalações
RUN node -v && npm -v && rustc --version && cargo --version

# Instalar Anchor Version Manager (AVM) e Anchor CLI
RUN cargo install --git https://github.com/coral-xyz/anchor avm --locked -j 2 && \
    /home/solana/.cargo/bin/avm install 0.30.1 && \
    /home/solana/.cargo/bin/avm use 0.30.1

# Instalar Solana CLI
RUN curl -sSfL https://release.anza.xyz/stable/install | sh

# Adicionar Solana CLI ao PATH
ENV PATH="/home/solana/.local/share/solana/install/active_release/bin:${PATH}"

# Verificar instalação do Solana CLI
RUN solana --version
RUN sudo npm install --global git-open

# Definir o diretório de trabalho
WORKDIR /home/solana/development

RUN --mount=type=cache,target=/home/solana/.cargo 

# Comando padrão
CMD ["bash"]