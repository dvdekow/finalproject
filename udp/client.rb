require 'socket'
require 'json'

sock = UDPSocket.new
# data = 'exit'
data = Hash.new
data['type'] = 'purchase'
data['userid'] = 'a5'
data['itemid'] = 'hp1'

sock.send(data.to_json, 0, '0.0.0.0', 3000)
sock.close