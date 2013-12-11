# APN

APN is a lightweight Apple Push Notification daemon for Ruby on Rails. APN runs as a daemon, works asynchronously using Redis and keeps persistent connection to Apple Push Notification Server.

## Prerequisites

APN works asynchronously, queueing messages from Redis, so you will need to have a running instance of the Redis server.

[Installation guide for Redis server](http://redis.io/topics/quickstart)

You will also need certificate file from Apple to be able to communicate with their server.
There are many guides how to do that. Put your certificate from Apple in your ```RAILS_ROOT/config/certs``` directory.

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
    --cert_file=MANDATORY        Location of the cert pem file
    --cert_password=OPTIONAL     Password for the cert pem file
    --redis_host=OPTIONAL        Redis hostname
    --redis_port=OPTIONAL        Redis port
    --queue=OPTIONAL             Name of the Redis queue
    --log_file=OPTIONAL          Log file (default STDOUT)
    --help                       Show help
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

If you want to run multiple instances, define ```queue``` for each one.

```ruby
message = {:alert => 'This is a test from APN!', :badge => 16}
queue   = 'apn_queue_1'
APN.queue(message, queue)
```
## Feedback service
You should periodically call the following feedback service to find out, to which devices you should stop sending notification (eg. they uninstall your app).


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
