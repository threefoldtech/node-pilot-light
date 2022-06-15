#!/bin/bash

root=${root:-"/mnt/storage/blockchain/ether"}

docker run -it --rm --name eth-000 --net host -v ${root}/keystore:/root/keystore -v ${root}/config/config.toml:/root/config.toml -v ${root}/data:/root/.ethereum ethereum/client-go:v1.10.14
