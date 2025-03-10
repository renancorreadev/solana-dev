#!/bin/bash

# Criar o diretório do ledger e garantir permissões
mkdir -p /home/solana/test-ledger
chmod -R 777 /home/solana/test-ledger

# Criar uma chave local se não existir
if [ ! -f "/home/solana/.config/solana/id.json" ]; then
    solana-keygen new --outfile /home/solana/.config/solana/id.json --no-bip39-passphrase
fi

# Configurar o Solana CLI para usar o localnet
solana config set --url http://localhost:8899
solana config set --keypair /home/solana/.config/solana/id.json

# Iniciar o Solana Local Validator
solana-test-validator --ledger /home/solana/test-ledger --reset --rpc-port 8899 --faucet-port 9900 --quiet &


