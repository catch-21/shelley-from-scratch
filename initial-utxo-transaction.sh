#!/bin/bash

[[ ! "$1" =~ ^[0-9]+$ ]] && echo "Node must be a number" && exit 1

[[ ! -d ./test-node/node$1/ ]] && echo "node$1 directory does not exist" && exit 1

#[[ ! "$2" =~ ^[0-9]+$ ]] && echo "Utxo must be a number" && exit 1

#[[ ! -f ./test-node/utxo-keys/utxo$2.vkey ]] && echo "utxo$2.vkey does not exist" && exit 1

[[ ! "$2" =~ ^[0-9]+$ ]] && echo "Lovelace must be a number" && exit 1

[[ ! "$3" =~ ^[0-9]+$ ]] && echo "TTL must be a number" && exit 1

mkdir -p test-node/txs

UTXO_KEYS=$(ls -l test-node/utxo-keys/*.vkey |wc -l)
for (( i=1; i<=$UTXO_KEYS; i++ ))
do
    initial_txin=$(cardano-cli shelley genesis initial-txin \
        --verification-key-file test-node/utxo-keys/utxo$i.vkey \
        --testnet-magic 666)
    echo "Initial TxIn is $initial_txin"
    
    # Make new keys
    cardano-cli shelley address key-gen \
        --verification-key-file test-node/txs/acct$i.vkey \
        --signing-key-file test-node/txs/acct$i.skey
	
    # Make new address
    addr=$(cardano-cli shelley address build \
        --payment-verification-key-file test-node/txs/acct$i.vkey \
        --testnet-magic 666)
    printf "Address is $addr\nWriting address to acct$i.addr\n"
    echo $addr >> ./test-node/txs/acct$i.addr

    # Build unsigned transaction body
    cardano-cli shelley transaction build-raw \
        --tx-in $initial_txin \
	--tx-out $addr+$(expr $2 / $UTXO_KEYS) \
        --ttl $3 \
        --fee 0 \
        --tx-body-file test-node/txs/tx$i.txbody

    # Signing the transacation
    cardano-cli shelley transaction sign \
      --tx-body-file test-node/txs/tx$i.txbody \
      --signing-key-file test-node/utxo-keys/utxo$i.skey \
      --testnet-magic 666 \
      --tx-file test-node/txs/tx$i.tx

    # Submitting the signed transaction
    CARDANO_NODE_SOCKET_PATH=test-node/node$1/node.sock \
        cardano-cli shelley transaction submit \
          --tx-file test-node/txs/tx$i.tx \
          --testnet-magic 666 \
          --shelley-mode
done
