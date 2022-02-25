#!/bin/bash
set -ex

# root is where the root directory os config and data will be on the host
scriptdir=$(dirname $0)
root=${root:-"/mnt/storage/blockchain/pokt"}

# random password
password="$(cat /proc/sys/kernel/random/uuid | sed s/-//g)"

# cleaning target directory
if [ -d ${root}/root ]; then
    rm -rf ${root}/root/*
fi

# ensure default directory layout
mkdir -p ${root}/root/config
mkdir -p ${root}/keys
mkdir -p ${root}/data

# copy config file from template
cp ${scriptdir}/config.json ${root}/root/config/

# create initial files
docker run -i --rm --name pokt-000 --entrypoint pocket \
    -v ${root}/root:/root/.pocket \
    rburgett/pocketcore:RC-0.7.0.1 start --mainnet || true

# create initial account
docker run -i --rm --entrypoint pocket \
    -v ${root}/root:/root/.pocket \
    -v ${root}/keys:/root/pocket-keys \
    -v ${root}/data:/root/pocket-data \
    rburgett/pocketcore:RC-0.7.0.1 accounts create --pwd $password

# get generated account
account=$(docker run -i --rm --entrypoint pocket \
    -v ${root}/root:/root/.pocket \
    -v ${root}/keys:/root/pocket-keys \
    -v ${root}/data:/root/pocket-data \
    rburgett/pocketcore:RC-0.7.0.1 accounts list | awk '{ print $2 }')

# set account as validator
docker run -i --rm --entrypoint pocket \
    -v ${root}/root:/root/.pocket \
    -v ${root}/keys:/root/pocket-keys \
    -v ${root}/data:/root/pocket-data \
    rburgett/pocketcore:RC-0.7.0.1 accounts set-validator $account --pwd $password

# configure chains.json
# TODO

# runs the blockchain
docker run -i --rm --net host --entrypoint pocket \
    -v ${root}/root:/root/.pocket \
    -v ${root}/keys:/root/pocket-keys \
    -v ${root}/data:/root/pocket-data \
    rburgett/pocketcore:RC-0.7.0.1 start --useCache --mainnet
