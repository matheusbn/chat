require 'socket'
require 'digest/sha1'
require './koala_socket'
require './util'

PORT = 3000

begin
  class Server
    def initialize(port)
      @server = TCPServer.open(port)

      listen
    end

    private


    def listen
      @threads = []

      loop do
        socket = Socket.new(@server.accept)
          socket.handshake!
          @threads << Thread.new do
            loop do
              begin
                socket.proccess_input!
              rescue RuntimeError => e
                log "There was an error with the client: #{e.message}"
                next
              end
            end
          end 
      end

      threads.each do |t|
        t.join
      end
    end

  end

  server = Server.new(PORT)
rescue Interrupt => e
  log "\nShutting server down..."
  exit
end