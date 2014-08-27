require 'socket'
require 'json'

sock = UDPSocket.new
# data = 'exit'
data = Hash.new
data['type'] = 'look'
data['userid'] = 'pagi111'
data['itemid'] = 'bb345'

sock.send(data.to_json, 0, '127.0.0.1', 33333)
sock.close