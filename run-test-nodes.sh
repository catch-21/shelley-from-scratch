# !/bin/bash

COUNT=$1
LOVELACE=$2

if [[ ! "$COUNT" =~ ^[0-9]+$ ]] # if not a number
then
    echo "Node count arg must be a number"
    exit 1
elif [[ $COUNT -lt 1 ]]
then
    echo "Node count arg must be greater than 0"
    exit 1
fi

if [[ ! "$LOVELACE" =~ ^[0-9]+$ ]] # if not a number
then
    echo "Lovelace arg must be a number"
    exit 1
elif [[ $LOVELACE -lt 1 ]]
then
    echo "Lovelace arg must be greater than 0"
    exit 1
fi

mkdir -p test-node

cardano-cli shelley genesis create --genesis-dir test-node/ --supply $LOVELACE --gen-genesis-keys $COUNT --gen-utxo-keys $COUNT --testnet-magic 666

# Node dirs, KES Keys and Operational Certificates
for ((i=1; i<=$COUNT; i++))
do
    mkdir -p test-node/node$i
    cardano-cli shelley node key-gen-KES --verification-key-file test-node/node$i/kes.vkey --signing-key-file test-node/node$i/kes.skey
    cardano-cli shelley node issue-op-cert --kes-verification-key-file test-node/node$i/kes.vkey --cold-signing-key-file test-node/delegate-keys/delegate$i.skey --operational-certificate-issue-counter test-node/delegate-keys/delegate$i.counter --kes-period 0 --out-file test-node/node$i/cert
done

# Shared Configuration File
if [[ ! -d "../cardano-node" ]]
then
    echo "cardano-node directory does not exist in level above"
    exit 1
fi
cp ../cardano-node/configuration/defaults/byron-mainnet/configuration.yaml test-node
sed -i 's/^Protocol: RealPBFT/Protocol: TPraos/' test-node/configuration.yaml
sed -i 's/^minSeverity: Info/minSeverity: Debug/' test-node/configuration.yaml
sed -i 's/^TraceBlockchainTime: False/TraceBlockchainTime: True/' test-node/configuration.yaml

#Topology Files:
i=1
while [ $i -lt $COUNT ];
do
    echo "{\"Producers\":[{\"addr\":\"127.0.0.1\",\"port\":300$[$i+1],\"valency\":1}]}" > test-node/node$i/topology.json
    ((i++))
done
echo "{\"Producers\":[{\"addr\":\"127.0.0.1\",\"port\":3001,\"valency\":1}]}" > test-node/node$COUNT/topology.json

# Run Nodes:
for((i=1;i<=$COUNT;i++)); do gnome-terminal -- cardano-node run --config test-node/configuration.yaml --topology test-node/node$i/topology.json --database-path test-node/node$i/db --socket-path test-node/node$i/node.sock --shelley-kes-key test-node/node$i/kes.skey --shelley-vrf-key test-node/delegate-keys/delegate$i.vrf.skey --shelley-operational-certificate test-node/node$i/cert --port 300$i; done
