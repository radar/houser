# Houser

This is the multitenancy gem that will be used in the Multitenancy with Rails book as an alternative method to PostgreSQL schemas which can have their own set of problems.

Houser provides you with two Rack environment variables which can then be used in your application to scope resources correctly. That is all it does for the time being, and it will probably do more in the future.

## Installation

Add this line to your application's Gemfile:

    gem 'houser'

And then execute:

    $ bundle

In `config/application.rb`, put this line:

    config.middleware.use Houser::Middleware, 
      :class_name => 'Model'

Where 'Model' is the class that you're scoping by. 

If you're using a TLD like `.co.uk` instead of `.com`, you will need to specify `tld_length` too:

    config.middleware.use Houser::Middleware, 
      :class_name => 'Model',
      :tld_length => 2

## Contributing

Please see [CONTRIBUTING.md](https://github.com/radar/houser/CONTRIBUTING.md)