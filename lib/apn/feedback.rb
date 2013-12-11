module APN
  class FeedbackItem
    attr_accessor :timestamp, :token

    def initialize(time, token)
      @timestamp = time
      @token = token
    end
  end

  class Feedback
    def initialize(options = {})
      options[:host]        ||= 'feedback.push.apple.com'
      options[:port]        ||= 2196
      options[:password]    ||= ''

      @cert = options[:cert]
      @password = options[:password]
      @host = options[:host]
      @port = options[:port]
    end

    def data
      APN.log(:info, 'Trying to get feedback from Apple push notification server...')

      @feedback ||= receive
    end

    def receive
      feedbacks = []
      while f = client.feedback
        feedbacks << f
      end

      APN.log(:info, 'Feedback received!')

      return feedbacks
    end

    def client
      @client ||= APN::Client.new(host: @host, port: @port, cert: APN.config.cert_file, password: APN.config.cert_password)
    end
  end
end