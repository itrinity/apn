require 'apn/daemon'
require 'apn/notification'
require 'apn/config'
require 'apn/feedback'
require 'apn/version'
require 'redis'

module APN
  class << self
    def queue(queue_name, message)
      self.redis.lpush(queue_name, message.to_json)
    end

    def redis
      @redis ||= Redis.new(:host => APN.config.redis_host, :port => APN.config.redis_port, :password => APN.config.redis_password)
    end

    def configure
      block_given? ? yield(Config) : Config
    end
    alias :config :configure
  end
end
