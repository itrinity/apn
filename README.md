# APN

APN is a lightweight Apple Push Notification daemon for Ruby on Rails. APN runs as a daemon, works asynchronously using Redis and keeps persistent connection to Apple Push Notification Server.

## Prerequisites

APN works asynchronously, queueing messages from Redis, so you will need to have a running instance of the Redis server.

[Installation guide for Redis server](http://redis.io/topics/quickstart)

You will also need certificate file from Apple to be able to communicate with their server.
There are many guides how to do that. Put your ```apn.pem``` certificate file from Apple to ```RAILS_ROOT/config/certs``` directory.

## Installation

Add this line to your application's Gemfile:

    gem 'apn'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install apn

## Daemon usage

Run daemon within your root Rails directory with this command:

```
Usage: apn start|stop|run [options]
    --cert=MANDATORY        Location of the cert pem file
    --password=OPTIONAL     Password for the cert pem file
    --queue=OPTIONAL        Name of the Redis queue
    --dir=OPTIONAL          Directory to start in (default root Rails dir)
    --logfile=OPTIONAL      Log file (default STDOUT)
    --help                  Show help
```

You can use ```apn stop``` instead of start in order to kill a running daemon with the options you provide.

## Client usage

```ruby
require 'apn'

message = {:alert => 'This is a test from APN!', :badge => 16}
APN.queue(message)
```

If you want to configure APN, just add configuration block.

```ruby
require 'apn'

APN.configure do |config|
  config.redis_host = 'localhost'
  config.redis_port = 6379
end

message = {:alert => 'This is a test from APN!', :badge => 16}
APN.queue(message)
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
