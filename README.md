# Houser

![Build Status](https://api.travis-ci.org/radar/houser.png?branch=master)

This is the multitenancy gem that is used in the Multitenancy with Rails book as an alternative method to PostgreSQL schemas which can have their own set of problems (such as backups taking an inordinately long time).

Houser provides you with two Rack environment variables which can then be used in your application to scope resources correctly. That is all it does for the time being, and it will probably do more in the future.

## Installation

Add this line to your application's Gemfile:

    gem 'houser'

And then execute:

    $ bundle

In `config/application.rb`, put this line:

``` ruby
config.middleware.use Houser::Middleware, 
  :class_name => 'Model'
```

Where 'Model' is the class that you're scoping by. 

If you're using a TLD like `.co.uk` instead of `.com`, you will need to specify `tld_length` too:

``` ruby
config.middleware.use Houser::Middleware, 
  :class_name => 'Model',
  :tld_length => 2
```

## Usage

There are two rack environment variables set by the Houser middleware that you can use throughout your application to scope resources. 

If no object is found for the subdomain the request is received on, both of these variables will be nil. 

### `env['X-Houser-Subdomain']`

The complete subdomain of the request. The following domains have the following subdomains:

* `sub1.example.com => sub1`
* `sub2.sub1.example.com => sub2.sub1`
* `sub1.example.co.uk => sub1`
* `sub2.sub1.example.co.uk => sub2.sub1`

### `env['X-Houser-Object']`

The instance of the Class that is found based on the subdomain. 

## Contributing

Please see [CONTRIBUTING.md](https://github.com/radar/houser/CONTRIBUTING.md)
