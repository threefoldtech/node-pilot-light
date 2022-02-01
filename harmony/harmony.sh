#!/bin/bash

root="/mnt/storage/blockchain/harmony"

docker run --rm -it --name harmony --net host -v ${root}/harmony.conf:/harmony/harmony.conf -v ${root}/data:/root/data -v ${root}/keystore:/root/keystore -v ${root}/run.sh:/run.sh --entrypoint /run.sh pocketfoundation/harmony:4.3.2-29-g1c450bbc
