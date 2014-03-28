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
        domain_name = domain_parts[(-options[:tld_length] - 1)..-1]
        subdomain = (domain_parts - domain_name).join('.')
        find_tenant(env, subdomain)
      end

      @app.call(env)
    end

    private

    def find_tenant(env, subdomain)
      object = options[:class].where(options[:subdomain_column].to_sym => subdomain).first
      if object
        env['X-Houser-Subdomain'] = subdomain
        env['X-Houser-Object'] = object
      end
    end
  end
end