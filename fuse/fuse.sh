#!/bin/bash

root="/mnt/storage/blockchain/fuse"

docker run --rm -it --net host -v ${root}/data:/root/data -v ${root}/keystore:/root/keystore -v ${root}/config/fuse.toml:/root/config.toml --name fuse-000 fusenet/node:2.0.1 -p --no-warp --config=/root/config.toml
