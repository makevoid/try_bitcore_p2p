Pool        = require('bitcore-p2p').Pool
BloomFilter = require('bitcore-p2p').BloomFilter
Networks    = require('bitcore-lib').Networks
Messages    = require('bitcore-p2p').Messages
_ = require 'underscore'
c = console

#
# var Peer = require('bitcore-p2p').Peer;
# var peer = new Peer({host: '52.63.37.246'});
# peer.connect();


block       = '000000000000000002a7df0960539e0c68ae506e2201bbe8e61eb2d2ddc36ed5'
address     = '1DTZQVtnUm1dVmpDg8eWgXUqQe3hhYgDry'
transaction = "873be417565c2e9fe9ee31db1064db83ea8e18069b6f8f93aa4f14180d0f7111"

pool = new Pool(network: Networks.livenet)


messages = new Messages()

code = new Buffer address, 'base64'
filter = BloomFilter.create 1000, 0.1
filter.insert code
msgFilter = messages.FilterLoad filter

getPeerFromPool = (cb) ->
  pool.connect()
  peerInv = (cb) ->
    cb = _.once cb
    pool.on 'peerinv', (peer, message) ->
      cb peer, message
  await peerInv defer peer, message
  c.log 'peerinv:', peer.host
  pool.disconnect()
  cb peer

# msgGetAddr = messages.GetAddr()
msgGetBlock  = messages.GetData.forBlock block
# msgGetTx     = messages.GetData.forTransaction transaction


mainLoop = ->
  await getPeerFromPool defer peer
  # c.log "PEER", peer
  peer.connect()
  await peer.on 'ready', defer()
  c.log peer.version, peer.subversion, peer.bestHeight

  peer.on 'tx', (msg) ->
    c.log "tx:", msg

  peer.on 'block', (msg) ->
    block = msg.block
    c.log "block:", "- txs_length:", block.transactions.length, "prev:", block.header.prevHash.toString 'hex'

  peer.on 'addr', (msg) ->
    c.log "addr:", "- ips:"
    for addr in msg.addresses
      c.log addr.ip.v4

  peer.on 'peerblock', (msg) ->
    c.log "peerblock:", msg

  peer.on 'merkleblock', (msg) ->
    c.log "merkleblock:", msg

  peer.on 'disconnect', ->
    c.log 'connection from peer closed, getting another peer...'
    mainLoop()

  # peer.sendMessage msgGetAddr
  # peer.sendMessage msgFilter
  peer.sendMessage msgGetBlock
  # peer.sendMessage msgGetTx

mainLoop()


# pool.on 'peerblock', (peer, message) ->
#   c.log message
# pool.on 'peermerkleblock', (peer, message) ->
#   c.log message
# pool.on 'block', (message) ->
#   c.log message
# pool.on 'merkleblock', (message) ->
#   c.log message
# pool.on 'tx', (message) ->
#   c.log message
# pool.on 'ready', () ->
#   c.log(pool);

# pool.sendMessage messageFilter
# pool.sendMessage lessRecent
