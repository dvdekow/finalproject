require 'rubygems'
require 'eventmachine'
require 'json'

class Reco < EventMachine::Connection
  def post_init
  	data = Hash.new
    data['type'] = 'look'
    data['userid'] = 'a3'
    data['itemid'] = 'hp3'
    send_data data.to_json
  end

  def receive_data(data)
  	p data
  	close_connection_after_writing
  end

  def unbind
  	p 'connection closed'
  end
end

EventMachine.run {
  EventMachine::connect '127.0.0.1', 8081, Reco
}