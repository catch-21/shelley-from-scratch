#!/bin/bash

[[ ! "$1" =~ ^[0-9]+$ ]] && echo "Node must be a number" && exit 1

[[ ! -d ./test-node/node$1/ ]] && echo "node$1 directory does not exist" && exit 1

[[ ! "$2" =~ ^[0-9]+$ ]] && echo "Utxo must be a number" && exit 1

[[ ! -f ./test-node/utxo-keys/utxo$2.vkey ]] && echo "utxo$2.vkey does not exist" && exit 1

utxo_addr=$(cardano-cli -- shelley address build \
    --payment-verification-key-file test-node/utxo-keys/utxo$2.vkey \
    --testnet-magic 666)

echo "UTxO addr is $utxo_addr"

CARDANO_NODE_SOCKET_PATH=test-node/node$1/node.sock \
    cardano-cli shelley query utxo \
    --testnet-magic 666 \
    --shelley-mode \
    --address $utxo_addr
