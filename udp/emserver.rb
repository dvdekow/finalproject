require 'rubygems'
require 'eventmachine'
require 'json'
require 'date'
require './collect'

class RecoServer
  def initialize(param = "")
  	@param = param
  end

  def run(defer)
    throw "This method needs to be implemented in subclasses"
  end

private
  def process(defer, time, message)
    EM.defer do
      sleep(time)
      defer.succeed(message)
    end   
  end
end

class LookIntr < RecoServer
  def run(defer)
  	process(defer, 1, "Completed look in 1 second with param = #{@param}")
  end
end

class PurchaseIntr < RecoServer
  def run(defer)
  	process(defer, 1, "Completed in purchase 1 second with param = #{@param}")
  end
end

class InvalidIntr <  RecoServer
  def run(defer)
    process(defer, 0, "Invalid")
  end
end

class RequestHandler
  INTR = {
  	"LOOK" => LookIntr,
  	"PURCHASE" => PurchaseIntr
  }
  INTR.default = InvalidIntr
  def self.parse(command)
  	type, param = command.split
  	INTR[type].new(param)
  end
end

class UDPHandler < EM::Connection
  def receive_data(command)
  	command.chomp!
    log("Received #{command}")
    RequestHandler.parse(command).run(callback)
  end

private
  def callback
  	EM::DefaultDeferrable.new.callback do |response|
  	  send_data(response + "\n")
      log(response)
    end
  end

  def log(message)
    puts "#{DateTime.now.to_s} : #{message}"
  end
end

EM.run do
  EM.open_datagram_socket('0.0.0.0', 8081, UDPHandler)
end
