#!/bin/bash

[[ ! "$1" =~ ^[0-9]+$ ]] && echo "Node must be a number" && exit 1

[[ ! -d ./test-node/node$1/ ]] && echo "node$1 directory does not exist" && exit 1

CARDANO_NODE_SOCKET_PATH=test-node/node$1/node.sock \
    cardano-cli shelley query protocol-parameters \
    --testnet-magic 666 \
    --shelley-mode
