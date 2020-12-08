#!/bin/bash

echo "Node number:" && read node
[[ ! "$node" =~ ^[0-9]+$ ]] && echo "Node must be a number" && exit 1
[[ ! -d ./test-node/node$node/ ]] && echo "node$node directory does not exist" && exit 1


#
#[[ ! "$1" =~ ^[0-9]+$ ]] && echo "Node must be a number" && exit 1

#[[ ! -d ./test-node/node$1/ ]] && echo "node$1 directory does not exist" && exit 1

[[ ! "$2" =~  ^[A-Za-z0-9#]+$ ]] && echo "A single tx-in must be provided. Format TxId#TxIx" && exit 1

[[ ! "$3" =~  ^[A-Za-z0-9_+]+$ ]] && echo "tx-out 1 must be provided. Format Address+Lovelace" && exit 1

[[ ! "$4" =~  ^[A-Za-z0-9_+]+$ ]] && echo "tx-out 2 must be provided. Format Address+Lovelace" && exit 1

[[ ! "$5" =~ .*.skey$ ]] && echo "Arg5=$5. Must be skey." && exit 1

[[ ! -f $5 ]] && echo "Arg2=$5. File does not exist." && exit 1

[[ ! "$6" =~ ^[0-9]+$ ]] && echo "TTL must be a number" && exit 1


# Build unsigned transaction body
cardano-cli shelley transaction build-raw \
    --tx-in $2 \
    --tx-out $3 \
    --tx-out $4 \
    --ttl $6 \
    --fee 0 \
    --tx-body-file test-node/txs/tx.txbody

echo "signing-key-file=$5"
# Signing the transacation
cardano-cli shelley transaction sign \
  --tx-body-file test-node/txs/tx.txbody \
  --signing-key-file $5 \
  --testnet-magic 666 \
  --tx-file test-node/txs/tx.tx

# Submitting the signed transaction
CARDANO_NODE_SOCKET_PATH=test-node/node$1/node.sock \
    cardano-cli shelley transaction submit \
      --tx-file test-node/txs/tx.tx \
      --testnet-magic 666 \
      --shelley-mode
