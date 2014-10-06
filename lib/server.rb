require 'socket'
require 'json'
require './collect'

BasicSocket.do_not_reverse_lookup = true
# Create socket and bind to address
data = ""
client = UDPSocket.new
client.bind('0.0.0.0', 33333)

collect = Collect.new
# collect.create_node("buyer","k1")
puts "Server start"

while !data.eql? "exit" do
	data, addr = client.recvfrom(1024) # if this number is too low it will drop the larger packets and never give them to you
	conv = JSON.parse(data)
	# collect.relation(conv['userid'],conv['itemid'],conv['type'])
	# test = collect.create_node(conv['tipe'],conv['userid'])
	# puts test
	puts "From addr: '%s', msg: '%s'" % [addr.join(','), conv['userid']]
	# jika data = lihat, data, id
end