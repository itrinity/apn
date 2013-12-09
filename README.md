# Apn

APN is a lightweight Apple Push Notification daemon for Ruby on Rails. APN works asynchronously using Redis and run as a daemon.

## Installation

Add this line to your application's Gemfile:

    gem 'apn'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install apn

## Daemon Usage

Run daemon by this command:

```
Usage: apn start [options]
    --cert=MANDATORY        Location of the cert pem file
    --password=OPTIONAL     Password for the cert pem file
    --dir=OPTIONAL          Directory to start in
    --logfile=OPTIONAL      Log file
    --help                  Show help
```

You can use ```apn stop``` instead of start in order to kill a running daemon with the options you provide.

## Client usage

```ruby
require 'apn'

APN.configure do |config|
  config.redis_host = 'localhost'
  config.redis_port = 6379
end

message = {:badge => 1, :alert => 'This is a test from APN!', :sound => 'flash.caf', :custom_properties => {:test_id => 1234, :happiness => true}}
queue_name = 'apn'

APN.queue(queue_name, message)
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
