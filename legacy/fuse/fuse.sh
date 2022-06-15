#!/bin/bash
set -ex

# root is where the root directory config and data will be on the host
scriptdir=$(dirname $0)
root=${root:-"/mnt/storage/blockchain/fuse"}

if [ -d ${root} ]; then
    rm -rf ${root}/keys
    rm -rf ${root}/conf
fi

# ensure default directory layout
mkdir -p ${root}/keys
mkdir -p ${root}/data
mkdir -p ${root}/conf

# copy config file from template and run script
cp ${scriptdir}/fuse.toml ${root}/conf/fuse.toml

docker run --rm -d --name fuse-000 --net host \
    -v ${root}/data:/root/data \
    -v ${root}/keys:/root/keystore \
    -v ${root}/conf/fuse.toml:/root/config.toml \
    fusenet/node:2.0.1 -p --no-warp --config=/root/config.toml
