#!/bin/bash

[[ ! "$1" =~ ^[0-9]+$ ]] && echo "Node must be a number" && exit 1

[[ ! -f $2 ]] && echo "Arg2=$2 - File does not exist. It must be a list of addresses." && exit 1

while read addr; do printf "\n$addr\n"; ./query-utxo.sh $1 $addr; done < $2
