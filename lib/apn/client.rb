require 'openssl'
require 'socket'

module APN
  class Client
    def initialize(options = {})
      @cert = options[:cert]
      @password = options[:password]
      @host = options[:host]
      @port = options[:port]

      @logger = APN::Log.new.write
    end

    def connect!
      @logger.info 'Connecting...'

      cert = self.setup_certificate
      @socket = self.setup_socket(cert)

      @logger.info 'Connected!'

      @socket
    end

    def setup_certificate
      @logger.info 'Setting up certificate...'
      @context      = OpenSSL::SSL::SSLContext.new
      @context.cert = OpenSSL::X509::Certificate.new(File.read(@cert))
      @context.key  = OpenSSL::PKey::RSA.new(File.read(@cert), @password)
      @logger.info 'Certificate created!'

      @context
    end

    def setup_socket(ctx)
      @logger.info 'Connecting...'

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
        @logger.info "Sending #{notification.device_token}: #{notification.json_payload}"
        socket.write(notification.to_bytes)
        socket.flush

        if IO.select([socket], nil, nil, 1) && error = socket.read(6)
          error = error.unpack('ccN')
          @logger.error "Encountered error in push method: #{error}, backtrace #{error.backtrace}"
          return false
        end

        @logger.info 'Message sent'

        true
      rescue OpenSSL::SSL::SSLError, Errno::EPIPE => e
        @logger.error "Encountered error: #{e}, backtrace #{e.backtrace}"
        @logger.info 'Trying to reconnect...'
        reset_socket
        @logger.info 'Reconnected'
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