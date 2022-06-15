import requests
import json

class RPC:
    def __init__(self):
        pass

    def call(self, endpoint, method):
        rpc = {"jsonrpc": "2.0", "method": method, "params": [], "id": 1}
        r = requests.post(endpoint, json=rpc)
        data = r.json()

        return data["result"]


class NetworkStatus:
    def __init__(self):
        self.rpc = RPC()

    def pokt(self):

        gql = {
            "operationName": "highestBlock",
            "variables":{},
            "query": "query highestBlock {\n  highestBlock {\n    item {\n      height\n      time\n       __typename\n    }\n    validatorThreshold\n    __typename\n  }\n}\n"
        }

        r = requests.post("https://poktscan.com/api/graphql?opname=getPoktNetworkStatus", json=gql)
        pokt = r.json()

        return pokt["data"]["highestBlock"]["item"]["height"]

    def fuse(self):
        number = self.rpc.call("https://explorer.fuse.io/api/eth-rpc", "eth_blockNumber")
        return int(number, 16)

    def harmony(self):
        number = self.rpc.call("https://api.s0.t.hmny.io", "hmy_blockNumber")
        return int(number, 16)


class BlockchainsStatus:
    def __init__(self):
        self.rpc = RPC()

    def pokt(self):
        r = requests.post("%s/%s" % ("http://127.0.0.1:8081", "/v1/query/height"))
        data = r.json()

        return data["height"]

    def harmony(self):
        number = self.rpc.call("http://127.0.0.1:9500", "hmy_blockNumber")
        return int(number, 16)

    def fuse(self):
        number = self.rpc.call("http://127.0.0.1:8545", "eth_blockNumber")
        return int(number, 16)

if __name__ == "__main__":
    n = NetworkStatus()
    b = BlockchainsStatus()

    chains = {
        "fuse": {"name": "Fuse", "now": 0, "network": 0},
        "pokt": {"name": "Pokt", "now": 0, "network": 0},
        "harm": {"name": "Harmony", "now": 0, "network": 0}
    }

    print("[+] fetching local nodes state")
    chains["fuse"]["now"] = b.fuse()
    chains["pokt"]["now"] = b.pokt()
    chains["harm"]["now"] = b.harmony()

    print("[+] fetching network state: fuse")
    chains["fuse"]["network"] = n.fuse()

    print("[+] fetching network state: pokt")
    chains["pokt"]["network"] = n.pokt()

    print("[+] fetching network state: harmony")
    chains["harm"]["network"] = n.harmony()

    print("[+] =================")

    for name in chains:
        chain = chains[name]
        print("[+] %-15s: % 12d / % 12d [% 3.1f %%]" % (chain["name"], chain["now"], chain["network"], (chain["now"] / chain["network"]) * 100))

