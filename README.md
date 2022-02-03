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

