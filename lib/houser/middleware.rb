require 'rack'

module Houser
  class Middleware
    attr_accessor :options

    def initialize(app, options={})
      @options = options
      @options[:subdomain_column] ||= "subdomain"
      @options[:class] = Object.const_get(options[:class_name])
      @options[:tld_length] ||= 1
      @app = app
    end

    def call(env)
      domain_parts = env['HTTP_HOST'].split('.')

      if domain_parts.length > 1 + options[:tld_length]
        subdomain = domain_parts[0]
        find_tenant(env, subdomain)
      end

      @app.call(env)
    end

    private

    def find_tenant(env, subdomain)
      object = options[:class].find_by(options[:subdomain_column].to_sym => subdomain)
      if object
        env['X-Houser-Subdomain'] = subdomain
        env['X-Houser-Object'] = object
      end
    end
  end
end