#!/bin/bash
set -ex

mkdir -p /mnt/cache

if [ -e /dev/vdb ]; then
    size=$(fdisk -l /dev/vdb | grep Disk | grep bytes | awk '{ print $5 }')

    if [ $size -gt 67108864 ]; then
        echo "[+] initializing cache disk"

        mkfs.ext4 /dev/vdb # FIXME: force yes ?
        mount /dev/vdb /mnt/cache

        echo "[+] cache disk ready"
    else
        echo "[-] device /dev/vdb: size too small ($size bytes)"
    fi

else
    echo "[-] no /dev/vdb found: skipping cache"
fi

mkdir -p /mnt/cache/readwrite
mkdir -p /mnt/cache/workdir

apt-get update
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release wget sudo

rm -f /usr/share/keyrings/docker-archive-keyring.gpg
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null


apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

mkdir /mnt/zdbfs

wget https://github.com/threefoldtech/0-db-fs/releases/download/v0.1.10/zdbfs-0.1.10-amd64-linux-static
chmod +x zdbfs-0.1.10-amd64-linux-static

wget https://github.com/threefoldtech/0-db/releases/download/v2.0.4/zdb-2.0.4-linux-amd64-static
chmod +x zdb-2.0.4-linux-amd64-static

wget https://github.com/threefoldtech/node-pilot-light/releases/download/v0.0.1/localzdb.tar
tar -xf localzdb.tar -C /tmp

useradd -m nodep -s /bin/bash
echo "nodep ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

usermod -aG docker nodep
usermod -aG sudo nodep

service docker start

wget https://raw.githubusercontent.com/threefoldtech/node-pilot-light/development/upstream/init.sh -O /home/nodep/init.sh
wget https://github.com/threefoldtech/node-pilot-light/releases/download/v0.0.1/tfnp.so -O /home/nodep/tfnp.so
wget https://builds.decentralizedauthority.com/node-pilot/v0.12.12/np -O /home/nodep/np

chmod +x /home/nodep/np
chmod +x /home/nodep/tfnp.so
chmod +x /home/nodep/init.sh

mkdir -p /home/nodep/.node-pilot/chains

# local zdb for temp
./zdb-2.0.4-linux-amd64-static \
    --data /tmp/localzdb-data --index /tmp/localzdb-index \
    --listen 127.0.0.1 \
    --background

./zdbfs-0.1.10-amd64-linux-static /mnt/zdbfs \
    -o mh=2a10:b600:1:0:8c4c:2ff:fe27:ce8c -o mn=399-6629-zdbfsxmeta \
    -o dh=2a10:b600:1:0:8c4c:2ff:fe27:ce8c -o dn=399-6629-zdbfsxdata \
    -o th=127.0.0.1 -o ts=hello \
    -o allow_other -o allow_root -o ro -o background

mount -t overlay overlay \
    -o lowerdir=/mnt/zdbfs,upperdir=/mnt/cache/readwrite,workdir=/mnt/cache/workdir \
    /home/nodep/.node-pilot/chains

chown nodep:nodep /home/nodep/.node-pilot
chown nodep:nodep /home/nodep/.node-pilot/chains
chown nodep:nodep /home/nodep/np
chown nodep:nodep /home/nodep/tfnp.so
chown nodep:nodep /home/nodep/init.sh

su - nodep -c /home/nodep/init.sh
