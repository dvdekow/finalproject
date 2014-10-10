require 'rubygems'
require 'eventmachine'
require 'json'
require './collect'

module RecoServer
  
  def collect
    @collect = Collect.new
  end
  
  def post_init
    puts "-- someone connected to the echo server!"
  end

  def receive_data data
  	conv = JSON.parse(data)
  	collect.relation(conv['userid'],conv['itemid'],conv['type'])
    send_data ">>> insert success"
  end
end

EventMachine::run {
	EventMachine::start_server "127.0.0.1", 8081, RecoServer
	puts 'running echo server on 8081'
}