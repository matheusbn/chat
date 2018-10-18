require './event_emitter'

class Socket
  include EventEmitter

  def initialize socket
    @socket = socket
  end

  def handshake
    http_request = ""
    while (line = @socket.gets) && (line != "\r\n")
      http_request += line
    end

    if matches = http_request.match(/^Sec-WebSocket-Key: (\S+)/)
      websocket_key = matches[1]
      log "Websocket handshake detected with key: #{ websocket_key }"

      response_key = Digest::SHA1.base64digest([websocket_key, "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"].join)
      log "Responding to handshake with key: #{ response_key }"

      @socket.write <<~eos 
      HTTP/1.1 101 Switching Protocols
      Upgrade: websocket
      Connection: Upgrade
      Sec-WebSocket-Accept: #{ response_key }

      eos

      log "Handshake completed. Starting to parse the websocket frame."
    else
      @socket.close
      raise "Aborting non-websocket connection"
    end

  end

  def proccess_input
    read_until_end_of_stream

    check_requirements


    payload_size = get_payload_size
    
    log "Payload size: #{ payload_size } bytes"

    mask = 4.times.map { @socket.getbyte }
    log "Got mask: #{mask}"

    data = payload_size.times.map { @socket.getbyte }
    log "Got masked data: #{data}"

    unmasked_data = data.each_with_index.map { |byte, i| byte ^ mask[i % 4] }

    log "Unmasked the data: #{unmasked_data}"

    parsed_data = unmasked_data.pack('C*').force_encoding('utf-8')
    log "Converted to a string: #{parsed_data}"
    parsed_data

    emit(:message, parsed_data)
  end

  def write message
    fin_and_opcode = 0b10000001
    output = [fin_and_opcode, message.size, message]

    @socket.write output.pack("CCA#{message.size}")
    
    log "Sending response: #{message}"
  end

  private
  
  def check_requirements
    first_byte = @socket.getbyte
    @second_byte = @socket.getbyte

    log 'Incoming Request'
    
    fin = first_byte & 0b10000000
    opcode = first_byte & 0b00001111

    raise "We don't support continuations" unless fin
    raise "We only support opcode 1" unless opcode == 1

    is_masked = @second_byte & 0b10000000
    
    raise "All frames sent to a server should be masked according to the websocket spec" unless is_masked

    log "Requirements checked successfully."
  end

  def get_payload_size
    payload_size = @second_byte & 0b01111111

    raise "We only support payloads < 126 bytes in length" unless payload_size < 126

    payload_size
  end

  def read_until_end_of_stream
    @socket.getbyte until @socket.nread <= 0
  end

end