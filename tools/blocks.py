import requests

# classic rpc call
targets = [
    {"name": "Harmony", "host": "127.0.0.1:9500", "request": "hmy_blockNumber"},
    {"name": "Fuse",    "host": "127.0.0.1:8545", "request": "eth_blockNumber"},
]

for target in targets:
    rpc = {"jsonrpc": "2.0", "method": target["request"], "params":[], "id":1}
    r = requests.post("http://%s" % target["host"], json=rpc)
    data = r.json()

    print("%-20s: block %d" % (target["name"], int(data["result"], 16)))


# pokt cal

# http://localhost:8081/v1/query/height
targets = [
    {"name": "Pokt", "host": "127.0.0.1:8081", "url": "/v1/query/height"},
]

for target in targets:
    r = requests.post("http://%s/%s" % (target["host"], target["url"]))
    data = r.json()

    print("%-20s: height %d" % (target["name"], data["height"]))

