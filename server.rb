require 'socket'

PORT = 3000


class Server
  def initialize(port)
    @clients = Hash.new
    @server = TCPServer.open(port)


    t = send
    listen
    t.join
  end

  private


  def send
    t = Thread.new do

      puts 'sending...'
      loop do
        message = input
        broadcast 'Server', messsage
      end

    end
  end


  def listen
    threads = []

    loop do
      client = @server.accept
      threads << Thread.new do
        puts 'listening...'
        
        client_name = client.gets.chomp.to_sym
        if @clients[client_name] != nil
          client.puts "Username already exists!"
          client.kill
        end
        @clients[client_name] = client
        
        puts @clients
        client.puts "Hey!"

        while line = client.gets
          puts "#{client_name}: #{line}"
          broadcast client_name, line
        end
      end
    end

    threads.each do |t|
      t.join
    end
  end


  def broadcast client_name = '', message
    @clients.each do |username, socket|
      socket.puts "#{client_name}: #{message}" unless client_name == username
    end
  end
  

  def input
    print '-> '
    gets.chomp
  end

end

server = Server.new(PORT)