path    = require('path')
decode  = require('./decode')
fs      = require('fs')
http    = require('http')
url     = require('url')
port    = 3000
dgram   = require 'dgram'
sock    = dgram.createSocket 'udp4'


sendHtml = (path, res) ->
  fs.readFile path, (err, html) ->
    res.writeHeader 200,
      'Content-Type'    : 'text/html'
      'Content-Length'  : html.length
    res.write html
    res.end()


# # toHexLiterals()
# Returns an array of hex literal strings:
#
#     ['0x33', '0xEF', '0xF9', ...]
toHexLiterals = (str) ->
  str.match(/\w{2}/g).map (byte) ->
    "0x#{byte}"


toBuffer = (str) ->
  new Buffer(toHexLiterals str)


sendDecoded = (req, res) ->
  query   = url.parse(req.url, true).query
  payload = query.payload

  return unless /\w{2}/g.test payload

  hex     = toHexLiterals payload
  decoded = decode(new Buffer(hex))

  res.writeHeader 200,
    'Content-Type'    : 'application/json'
  res.end JSON.stringify(decoded)


http.createServer (req, res) ->
  parsedUrl = url.parse(req.url)

  switch parsedUrl.pathname
    when '/' then sendHtml( './lib/form.html', res )
    when '/decode' then sendDecoded(req, res)
    else
      res.writeHeader 200
      res.end()
.listen(port)