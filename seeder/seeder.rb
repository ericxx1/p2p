require 'socket'

module Seed
	class Seeder
	@port = 5666
	SIZE = 1024 * 1024 * 10
		@reseed = TCPServer.new @port
		Thread.start @reseed.accept do |peer|
		puts "Valid node connected.... Sending over peer-dump"
		  File.open('peers', 'rb') do |file|
             while chunk = file.read(SIZE)
             peer.write(chunk)
             end
           end 
           puts "Sent.. Closing connection.."
           @reseed.close
        end
     end
  end          
Seed::Seeder.new
