# Cardano HTTP Bridge

[![Build Status](https://travis-ci.org/input-output-hk/cardano-http-bridge.svg?branch=master)](https://travis-ci.org/input-output-hk/cardano-http-bridge)

The cardano HTTP bridge provides a JSON REST API to query:

* Blocks;
* Pack of blocks (Organized by epochs);
* Protocol genesis configuration file;
* TIP (the latest work of the network);
* UTxOs

And to post transactions

# How to build

1. you need to [install the rust toolchain](https://www.rust-lang.org/tools/install);
2. you need to build the project: `cargo run --release`

# How to start a new http bridge instance

You are interested only about the `start` command:

Options:

* `--networks-dir <NETWORKS DIRECTORY>`    the relative or absolute directory of the networks to server, default is under the `${HOME}/.hermes/networks/` directory
* `--port <PORT NUMBER>`                   set the port number to listen to [default: 80]
* `--template <TEMPLATE>...`               either 'mainnet' or 'testnet2'; may be given multiple times [default: mainnet]  [possible values: mainnet, staging, testnet2]

Example, if you wish the http-bridge to server mainnet and staging:

```
cardano-http-bridge start --port=80 --template=mainnet,staging
```

# Offered APIs:

## GET: `/:network/block/:blockid` query block

This allows to query a block in its binary format.

* `:network` is any of the network passed to the `--template` options at startup.
* `:blockid` the hash identifying a block within the blockchain

Example:

```
wget http://localhost:8080/mainnet/block/6abb9309dd72dd5901fc6dad22caaefc15bd08d5f297503001a9efdaee1eec2b
```

## GET: `/:network/epoch/:epochid`

This allows you to query a whole epoch in its binary format.

* `:network` is any of the network passed to the `--template` options at startup.
* `:epochid` the epoch number (0, 1, 2 ...)

Example:

```
wget http://localhost:8080/mainnet/epoch/2
```

## GET: `/:network/height/:blockHeight`

This allows you to query a single block in its binary format.

* `:network` is any of the network passed to the `--template` options at startup.
* `:blockHeight` the height of the queried block (starting from 1, cuz a chain of one block has a height of 1)

:warning: Note that Epoch-Boundary-Blocks are not semantically a part of the chain, because they don't increase the block `difficulty` number, and therefore they technically **cannot** be queried by this endpoint. Althought full epochs, returned by the `/epoch/:epochId` endpoint do contain EBB, because they are semantically a part of an epoch.

Example:

```
wget http://localhost:8080/mainnet/height/45000
```

## GET: `/:network/status`

This allows you to query the current status of the bridge syncing.

Example:

```
wget http://localhost:8080/mainnet/status
```

Response format:

```
{
  "tip": {
    "local": {
      "slot": [<Epoch>, <Slot>],
      "height": <Height>,
      "hash": <Hash>
    },
    "remote": {
      "slot": [<Epoch>, <Slot>],
      "height": <Height>,
      "hash": <Hash>
    }
  },
  "packedEpochs": <PackedEpochs>
}
```

Where:
- `<Epoch>` - integer number of the tip epoch (0+)
- `<Slot>` - inetger number of the tip in-epoch slott (currently between 0 and 21599)
- `<Height>` - integer number of the tip block height (1+)
- `<Hash>` - string tip block ID hash
- `<PackedEpochs>` - integer number of how many consequent epochs bridge already has in a packed form. Endpoint to query full epochs will only return you a full epoch if it has been fully packed, and bridge implements somewhat complex logic on when previous finished epochs get packed, depending on the network stability parameter, so you can use this status field to quickly check whether it's possible to query some full epoch.

Example response:
```
{
  "packedEpochs": 57,
  "tip": {
    "local": {
      "hash": "48047eb233168def823a1085ee324d34a6412dfbb7374f310d6548e3309a33d8",
      "height": 1236900,
      "slot": [
        57,
        5822
      ]
    },
    "remote": {
      "hash": "400e86695f7e1187fbcf862021820d8815aaf58f39b044b7aca43bb00fe1ee16",
      "height": 1237072,
      "slot": [
        57,
        5994
      ]
    }
  }
}
```

## GET: `/:network/genesis/:hash`

This allows you to query a genesis file, if you know the hash of the genesis file you can query it here:

* `:network` is any of the network passed to the `--template` options at startup.
* `:hash` the hash of the genesis file

## GET: `/:network/tip`

Download the block header (binary format) of the TIP of the blockchain: the latest known block.

* `:network` is any of the network passed to the `--template` options at startup.

Example:

```
wget http://localhost:8080/mainnet/tip
```

## POST: `/:network/txs/signed`

Allows you to send a signed transaction to the network. The transaction will then be
disseminated to the different nodes it knows of:

* `:network` is any of the network passed to the `--template` options at startup.

The body of the request is the base64 encoded signed transaction.

## GET: `/:network/utxos/:address`

Allows you to query utxos in JSON format given:

* `:network` is any of the network passed to the `--template` options at startup.
* `:address` base58 encoding of an address

Example query:

```
curl http://localhost:8080/mainnet/utxos/2cWKMJemoBamE3kYCuVLq6pwWwNBJVZmv471Zcb2ok8cH9NjJC4JUkq5rV5ss9ALXWCKN
```

Possible response:
```json
[
    {
        "address": "2cWKMJemoBamE3kYCuVLq6pwWwNBJVZmv471Zcb2ok8cH9NjJC4JUkq5rV5ss9ALXWCKN",
        "coin": 310025,
        "index": 0,
        "txid": "89eb0d6a8a691dae2cd15ed0369931ce0a949ecafa5c3f93f8121833646e15c3"
    }
]
```

## GET: `/:network/chain-state/:epochid`

## GET: `/:network/chain-state-delta/:epochid/:to`
