log = (x...) -> console.log x...

_ = require 'lodash'
CacheLoop = require 'taky-cache-loop'
$ = require 'jquery'

last_socket_url = null
last_socket_obj = null

FEN = {
  last_updated: null
  fen: null
}

SOCKET = new CacheLoop({
  interval: '1 second'
  fn: ((cb) =>
    sri = window.lichess.sri
    game_id = location.href.split('/').pop()
    if !sri or !game_id then return cb new Error 'Unable to parse socket information'
    socket_url = "wss://socket2.lichess.org/play/#{game_id}/v5?sri=#{sri}&v=0"

    _bind_socket = ((socket) ->
      socket.onmessage = (e) ->
        try
          fen = JSON.parse(e.data).d.fen
          ply = JSON.parse(e.data).d.ply
        catch e
          return false
        if !fen or !ply then return false
        if ply % 2
          fen += ' b'
        else
          fen += ' w'
        FEN.fen = fen
        FEN.last_updated = new Date
      return socket
    )

    if socket_url isnt last_socket_url
      last_socket_url = socket_url
      return cb null, (last_socket_obj = _bind_socket(new WebSocket(socket_url)))
    return cb null, last_socket_obj
  )
})

log 'helo@', CONFIG



