require 'socket'
BasicSocket.do_not_reverse_lookup = true
# Create socket and bind to address
data = ""
client = UDPSocket.new
client.bind('0.0.0.0', 33333)

puts "Server start"

while !data.eql? "exit" do
	data, addr = client.recvfrom(1024) # if this number is too low it will drop the larger packets and never give them to you
	puts "From addr: '%s', msg: '%s'" % [addr.join(','), data]
	# jika data = lihat, data, id
	#
end

#if data.eql? "exit" 
#  client.close
#else
#  puts "From addr: '%s', msg: '%s'" % [addr.join(','), data]
#end
