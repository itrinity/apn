require 'openssl'
require 'socket'

module APN
  class Client
    def initialize(options = {})
      @cert = options[:cert]
      @password = options[:password]
      @host = options[:host]
      @port = options[:port]
    end

    def connect!
      APN.log(:info, 'Connecting...')

      cert = self.setup_certificate
      @socket = self.setup_socket(cert)

      APN.log(:info, 'Connected!')

      @socket
    end

    def setup_certificate
      APN.log(:info, 'Setting up certificate...')
      @context      = OpenSSL::SSL::SSLContext.new
      @context.cert = OpenSSL::X509::Certificate.new(File.read(@cert))
      @context.key  = OpenSSL::PKey::RSA.new(File.read(@cert), @password)
      APN.log(:info, 'Certificate created!')

      @context
    end

    def setup_socket(ctx)
      APN.log(:info, 'Connecting...')

      socket_tcp = TCPSocket.new(@host, @port)
      OpenSSL::SSL::SSLSocket.new(socket_tcp, ctx).tap do |s|
        s.sync = true
        s.connect
      end
    end

    def reset_socket
      @socket.close if @socket
      @socket = nil

      connect!
    end

    def socket
      @socket ||= connect!
    end

    def push(notification)
      begin
        APN.log(:info, "Sending #{notification.device_token}: #{notification.json_payload}")
        socket.write(notification.to_bytes)
        socket.flush

        if IO.select([socket], nil, nil, 1) && error = socket.read(6)
          error = error.unpack('ccN')
          APN.log(:error, "Encountered error in push method: #{error}, backtrace #{error.backtrace}")
          return false
        end

        APN.log(:info, 'Message sent')

        true
      rescue OpenSSL::SSL::SSLError, Errno::EPIPE => e
        APN.log(:error, "Encountered error: #{e}, backtrace #{e.backtrace}")
        APN.log(:info, 'Trying to reconnect...')
        reset_socket
        APN.log(:info, 'Reconnected')
      end
    end

    def feedback
      if bunch = socket.read(38)
        f = bunch.strip.unpack('N1n1H140')
        APN::FeedbackItem.new(Time.at(f[0]), f[2])
      end
    end
  end
end