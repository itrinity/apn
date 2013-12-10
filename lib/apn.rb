require 'apn/daemon'
require 'apn/notification'
require 'apn/config'
require 'apn/feedback'
require 'apn/client'
#require 'apn/log'
require 'apn/version'
require 'redis'

module APN
  class << self
    def queue(message, queue_name = 'apn_queue')
      self.redis.lpush(queue_name, message.to_json)
    end

    def redis
      @redis ||= Redis.new(:host => APN.config.redis_host, :port => APN.config.redis_port, :password => APN.config.redis_password)
    end

    def logger=(logger)
      @logger = logger
    end

    def logger
      @logger ||= Logger.new(logfile)
    end

    def log(level, message = nil)
      level, message = 'info', level if message.nil? # Handle only one argument if called from Resque, which expects only message

      return false unless logger && logger.respond_to?(level)
      logger.send(level, "#{Time.now}: #{message}")
    end

    def log_and_die(msg)
      logger.fatal(msg)
      raise msg
    end

    def logfile
      APN.config.logfile ? APN.config.logfile : STDOUT
    end

    def configure
      block_given? ? yield(Config) : Config
    end
    alias :config :configure
  end
end

require 'apn/railtie' if defined?(Rails)
