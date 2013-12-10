require 'redis'
require 'logger'
require 'active_support/ordered_hash'
require 'active_support/json'
require 'base64'
require 'apn/client'
require 'apn/notification'
require 'apn/config'
#require 'apn/log'

module APN
  class Daemon
    attr_accessor :redis, :host, :apple, :cert, :queue, :connected, :logger, :airbrake

    def initialize(options = {})
      options[:redis_host]  ||= 'localhost'
      options[:redis_port]  ||= '6379'
      options[:host]        ||= 'gateway.sandbox.push.apple.com'
      options[:port]        ||=  2195
      options[:queue]       ||= 'apn_queue'
      options[:password]    ||= ''
      raise 'No cert provided!' unless options[:cert]

      redis_options = { :host => options[:redis_host], :port => options[:redis_port] }
      redis_options[:password] = options[:redis_password] if options.has_key?(:redis_password)

      @redis = Redis.new(redis_options)
      @queue = options[:queue]
      @cert = options[:cert]
      @password = options[:password]
      @host = options[:host]
      @port = options[:port]
      @dir = options[:dir]

      APN.configure do |config|
        config.logfile = options[:logfile]
      end

      APN.log(:info, "Listening on queue: #{self.queue}")
    end

    def run!
      @last_notification = nil

      loop do
        begin
          message = @redis.blpop(self.queue, 1)
          if message
            @notification = APN::Notification.new(JSON.parse(message.last,:symbolize_names => true))

            send_notification
          end
        rescue Exception => e
          if e.class == Interrupt || e.class == SystemExit
            APN.log(:info, 'Shutting down...')
            exit(0)
          end

          APN.log(:error, "Encountered error: #{e}, backtrace #{e.backtrace}")

          APN.log(:info, 'Trying to reconnect...')
          client.connect!
          APN.log(:info, 'Reconnected')

          client.push(@notification)
        end
      end
    end

    def send_notification
      if @last_notification.nil? || @last_notification < Time.now - 3600
        APN.log(:info, 'Forced reconnection...')
        client.connect!
      end

      client.push(@notification)

      @last_notification = Time.now
    end

    def client
      @client ||= APN::Client.new(host: @host, port: @port, cert: @cert, password: @password, dir: @dir, queue: @queue)
    end
  end
end