require 'socket'

HOST = 'localhost'
PORT = 3000


class Client
  def initialize(host, port)
    @socket = TCPSocket.open(host, port)


    print "Yo whats ur username: "
    @socket.puts input
    
    t1 = Thread.new do listen_response end
    t2 = Thread.new do send_request end
    
    t1.join
    t2.join
  end

  private

  def send_request
    loop do
      message = input
      close_connection if message == '!leave'
      @socket.puts message
    end
  end

  
  def listen_response
    while line = @socket.gets
      puts
      puts line.chomp
      print '-> '
    end      
  end


  def input
    print '-> '
    gets.chomp
  end

  def close_connection
    @socket.close
  end
end

client = Client.new(HOST, PORT)