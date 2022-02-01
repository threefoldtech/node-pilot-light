#!/bin/bash

root="/mnt/storage/blockchain/pokt"

docker run -i --rm --name pokt-000 --entrypoint pocket -v ${root/root:/root/.pocket rburgett/pocketcore:RC-0.7.0.1 start --mainnet

docker run -i --rm --entrypoint pocket -v ${root}/root:/root/.pocket -v ${root}/keys:/root/pocket-keys -v ${root}/data:/root/pocket-data rburgett/pocketcore:RC-0.7.0.1 accounts create --pwd 35384eb419457f6eac427cd15c3c4e3b415c3eaed0d2c9203d6f92f405a39778

# get account id

docker run -i --rm --entrypoint pocket -v ${root}/root:/root/.pocket -v ${root}/keys:/root/pocket-keys -v ${root}/data:/root/pocket-data rburgett/pocketcore:RC-0.7.0.1 accounts set-validator 0c089dde4fdb0873e57b9b49a4e85e9fcf3801ef --pwd 35384eb419457f6eac427cd15c3c4e3b415c3eaed0d2c9203d6f92f405a39778

docker run -i --rm --net host --entrypoint pocket -v ${root}/root:/root/.pocket -v ${root}/keys:/root/pocket-keys -v ${root}/data:/root/pocket-data rburgett/pocketcore:RC-0.7.0.1 start --useCache --mainnet
