# node-pilot-light

Node pilot light is a similar to node-pilot but open-source and stripped down.

# Run

Each subdirectory is for a specific chain. Just editing the `root` variable should be enough.
This require docker.

For each blockchain, the actual `db` is always in the `data` directory on the container.
Ensure that directory is a volume pointing to the database (zdbfs, overlay, whatever).

# Chains

Generating chains.json for pokt is not yet supported. There is an example in the `pokt/chains.json` file.
This file makes the link between chains and pokt.

Here are the list of IDs for chains:
https://docs.pokt.network/home/resources/references/supported-blockchains#mainnet-relaychains

# Overlayfs

In order to use zdbfs as read-only backend, first mount a zdb with database inside:
```
mkdir /mnt/zdbfs
zdbfs /mnt/zdbfs -o mh=[metadata-host] -o mn=[metadata-namespace] -o ms=[metadata-secret] \
    -o dh=[data-host] -o dn=[data-namespace] -o ds=[data-password] \
    -o th=[temp-host] -o tn=[temp-namespace] -o ts=[temp-password]
```

Then to get zdbfs as read-only layer and get write locally, use overlayfs:
```
mkdir /mnt/overlay
mount -t overlay overlay -o lowerdir=/mnt/zdbfs,upperdir=/somewhere/readwrite,workdir=/somewhere/workdir /mnt/overlay
```

- `lowerdir` is the `read-only` layer
- `upperdir` is where new `read-write` data will be written
- `workdir` is a directory where overlayfs needs to write `temporary` stuff

Note: upperdir and workdir needs some feature on the fs, which are only implemented in: ext2, ext3, ext4,
UDF, Minix, tmpfs, XFS (Linux 3.15); Btrfs (Linux 3.16); F2FS (Linux 3.16); and ubifs (Linux 4.9)

# Public Testnet Overlay

**WARNING**: doing bad commands here can break remote public things. Don't forget `-o ro` flags.

There is a public (on testnet) zdb, with `pokt` and `fuse` database in as a test.
```
./zdbfs /mnt/zdbfs -o ro \
    -o mh=2a10:b600:1:0:b075:a3ff:fe67:f2fc -o mn=399-2714-bc1meta -o ms=b1-meta-pwd \
    -o dh=2a10:b600:1:0:b075:a3ff:fe67:f2fc -o dn=399-2714-bc1data -o ds=b1-data-pwd \
    -o th=2a10:b600:1:0:b075:a3ff:fe67:f2fc -o tn=399-2714-bc1temp -o ts=b1-temp-pwd
```

This will mount a **read-only** (but cache flush allowed) zdbfs locally using remote public zdb.

Now we need to use that `zdbfs` as read-only layer of `overlayfs`:
```
mkdir -p /mnt/overlay/readwrite
mkdir -p /mnt/overlay/workdir
mkdir -p /mnt/overlay/mountpoint

mount -t overlay overlay -o lowerdir=/mnt/zdbfs,upperdir=/mnt/overlay/readwrite,workdir=/mnt/overlay/workdir /mnt/overlay/mountpoint
```

# Mounting zdbfs data to chains data

Each blockchain have their own data directory, defined by `${root}/data` variable in each deploy script.

In order to use `overlayfs as data endpoint, we can easily **mount-bind** them:
```
mkdir -p /mnt/storage/blockchain/pokt/data
mount -o bind /mnt/overlay/mountpoint/pokt /mnt/storage/blockchain/pokt/data
````

This will make the database available to pokt expected database directory

The same needs to be done with other chains.

# Pokt configuration

A public endpoint needs to be available for pokt to interract, this endpoint is configured in `pokt/config.json` file (line 58).
This can use public ip, not needed to be domain name.
```
"ExternalAddress": "tcp://1.2.3.4:26656",
```

# Pokt stake

When doing the validator stake, a service URI needs to point to pokt, via HTTPS:
https://docs.pokt.network/core/guides/quickstart#stake-the-validator

I don't know exactly where that should point right now
