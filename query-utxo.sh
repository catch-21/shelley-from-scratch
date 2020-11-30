#!/bin/bash

[[ ! "$1" =~ ^[0-9]+$ ]] && echo "Node must be a number" && exit 1

[[ ! -d ./test-node/node$1/ ]] && echo "node$1 directory does not exist" && exit 1

[[ ! "$2" =~  ^[A-Za-z0-9_]+$ ]] && echo "Arg2=$2 - A single address must be provided" && exit 1

CARDANO_NODE_SOCKET_PATH=test-node/node$1/node.sock \
    cardano-cli shelley query utxo \
    --testnet-magic 666 \
    --shelley-mode \
    --address $2
