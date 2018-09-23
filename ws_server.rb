require 'socket'
require 'digest/sha1'

PORT = 3000


class Server
  def initialize(port)
    @server = TCPServer.open(port)

    listen
  end

  private


  def listen
    threads = []

    loop do
      socket = @server.accept
      threads << Thread.new do
        puts 'Incoming Request'

        http_request = ""
        while (line = socket.gets) && (line != "\r\n")
          http_request += line
        end


        handshake_did_complete = handshake http_request, socket
        next unless handshake_did_complete


        first_byte = socket.getbyte
        second_byte = socket.getbyte
        
        check_requirements first_byte, second_byte
        payload_size = get_payload_size second_byte
        
        STDERR.puts "Payload size: #{ payload_size } bytes"


        mask = 4.times.map { socket.getbyte }
        STDERR.puts "Got mask: #{mask}"


        data = payload_size.times.map { socket.getbyte }
        STDERR.puts "Got masked data: #{data}"


        unmasked_data = data.each_with_index.map { |byte, i| byte ^ mask[i % 4] }


        STDERR.puts "Unmasked the data: #{unmasked_data}"

        parsed_data = unmasked_data.pack('C*').force_encoding('utf-8')
        STDERR.puts "Converted to a string: #{parsed_data}"
      end
    end

    threads.each do |t|
      t.join
    end
  end

  def handshake http_request, socket
    if matches = http_request.match(/^Sec-WebSocket-Key: (\S+)/)
      websocket_key = matches[1]
      STDERR.puts "Websocket handshake detected with key: #{ websocket_key }"

      response_key = Digest::SHA1.base64digest([websocket_key, "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"].join)
      STDERR.puts "Responding to handshake with key: #{ response_key }"

      socket.write <<~eos 
      HTTP/1.1 101 Switching Protocols
      Upgrade: websocket
      Connection: Upgrade
      Sec-WebSocket-Accept: #{ response_key }

      eos

      STDERR.puts "Handshake completed. Starting to parse the websocket frame."

      true
    else
      STDERR.puts "Aborting non-websocket connection"
      socket.close
    end

  end



  def check_requirements first_byte, second_byte
    fin = first_byte & 0b10000000
    opcode = first_byte & 0b00001111

    raise "We don't support continuations" unless fin
    raise "We only support opcode 1" unless opcode == 1

    is_masked = second_byte & 0b10000000
    
    raise "All frames sent to a server should be masked according to the websocket spec" unless is_masked
  end

  def get_payload_size byte
    payload_size = byte & 0b01111111

    puts 1
    raise "We only support payloads < 126 bytes in length" unless payload_size < 126
    puts payload_size
    

    payload_size
  end


end

server = Server.new(PORT)