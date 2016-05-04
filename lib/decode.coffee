# # Decode Payload

util = require 'util'

# parse functions for each message type
parse =
  '2':  require('./msg-type-2')
  '5':  require('./msg-type-5')
  '10': require('./msg-type-10')


module.exports = (msg, rinfo) ->

  # attributes common to all message types
  common =
    mobileId:   msg.slice(2, 7).toString('hex')
    msgType:    msg.readUInt8 10
    seqNumber:  msg.readUInt16BE 11
    updateTime: (msg.readUInt32BE(13) * 1000)

  # attributes specific to message type
  parsed = parse["#{common.msgType}"](msg)
  
  util._extend parsed, common