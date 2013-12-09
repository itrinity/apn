require 'logger'

module APN
  class Log
    def initialize(options = {})
    end

    def write
      @logger ||= set_logger
    end

    def set_logger
      @logger = Logger.new(@logfile) if logfile
    end

    def logfile
      @logfile = APN.config.logfile
    end
  end
end