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
      @sockets = []

      loop do
        socket = Socket.new(@server.accept)


        socket.on :message do |message|
          puts message
        end


        @sockets << socket
        socket.handshake!
        @threads << Thread.new do
          loop do
            begin
              socket.proccess_input!


              socket.write "Loud and clear!"

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

    private

    def broadcast message
      @sockets.each do |socket|
        socket.write message
      end
    end

  end

  server = Server.new(PORT)

rescue Interrupt => e
  log "\nShutting server down..."
  exit
end