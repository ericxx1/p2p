require 'socket'
require 'ipaddr'
require 'net/http'
require_relative 'utils/colors/colorize'

module EricHouse
class Spinner
  include Enumerable
  def each
    loop do
      yield '|'
      yield '/'
      yield '-'
      yield '\\'
    end
  end
end
  class Peer
    include EricHouse::Colorize
    
    def initialize
      @port = '4545'
      unless File.exist? 'destination.txt'
        require_relative 'utils/gen.rb'
      end
      @destination = File.read 'destination.txt'
      @destination.chomp!
      get_my_ip
      
      puts "[Your real IP is:#{@my_ip}]"
		  puts "#{yellow 'Welcome to the Light.side of the internet'}"
		  puts "[#{purple 'Your peer Destination is: '}#{green @destination}]"
      Thread.abort_on_exception = true
      start_peer
    end
    
    def get_my_ip
      http = Net::HTTP.new 'whatismyip.akamai.com', 80
      @my_ip = IPAddr.new http.get("/").body
    end
    def spinny 
	  spinner = Spinner.new.enum_for(:each)
	  $stdout.sync = true
	  1.upto(100) do |i|
	  printf("\rBootstrapping with reseeder %s", spinner.next)
	  sleep(0.05)
	end
  end
  
    def start_peer
      @socket = TCPServer.new @port
      puts "Opened listening socket on port #{@port}"
      
      local
      reseed
      join
    end
    
    def local
      @local = Thread.new do
        puts 'Client now accepting fellow peers'
        
        loop do
          Thread.start @socket.accept do |peer|
            puts "Incoming connection" 
            whois = @peer.gets
            puts whois
            
            @routers = Thread.new do
              if(whois =~ /PEER/)
                @cntpeername = @peer.gets.chomp
                @peername = @peer.puts @urpeer
                puts "Peer #{@cntpeername} connected"
              end
			end
		  end
		end
	  end		
      def reseed
        @reseed = Thread.new do
        sleep(0.01)
          reseeders = File.readlines("reseeders").each do |reseeder|
            reseeder.chomp!
            seedhost, seedport = reseeder.split(":")
            sleep(5)
            size = 1024 * 1024 * 10
            q = TCPSocket.open seedhost, seedport do |socket|
            #q.puts "SEEDME"
            puts "Connected to reseeder"
            puts "Reciveing peer list"
            require 'benchmark'
            time = Benchmark.realtime do
				File.open('peers', 'w') do |file|
					while chunk = socket.read(size)
					file.write(chunk)
				  end
                end
             end
          end
            peerlist = File.readlines("peers").each do |peers|
            peers.chomp!
            sleep(5)
            q = TCPSocket.new peers, @port
            q.puts "PEER"
            q.puts @urpeer
            outpeer = q.gets.chomp
            puts "Connected to Peer #{outpeer}"
          end
        end
      end
      
      def join
        @local.join
        @routers.join
        @reseed.join
        @websites.join
        @ircservers.join
      end
    end
  end
end
end
EricHouse::Peer.new
