require 'rubygems'
require 'eventmachine'
require 'json'

class Reco < EventMachine::Connection
  def post_init
  	data = Hash.new
    data['type'] = 'look'
    data['userid'] = 'a2'
    data['itemid'] = 'hp2'
    send_data data.to_json
  end

  def receive_data(data)
  	p data
  end
end

EventMachine.run {
  EventMachine::connect '127.0.0.1', 8081, Reco
}