#!/bin/bash
set -ex

# root is where the root directory os config and data will be on the host
scriptdir=$(dirname $0)
root=${root:-"/mnt/storage/blockchain/harmony"}

# ensure default directory layout
mkdir -p ${root}/keys
mkdir -p ${root}/data

# copy config file from template and run script
cp ${scriptdir}/harmony.conf ${root}/harmony.conf
cp ${scriptdir}/run.sh ${root}/run.sh

docker run --rm -it --name harmony --net host --entrypoint /run.sh \
    -v ${root}/harmony.conf:/harmony/harmony.conf \
    -v ${root}/data:/root/data \
    -v ${root}/keys:/root/keystore \
    -v ${root}/run.sh:/run.sh \
    pocketfoundation/harmony:4.3.2-29-g1c450bbc

# run.sh wrapper is needed for an obscure reason
# could not make it works without it for now
