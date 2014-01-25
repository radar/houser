require 'houser/middleware'
require 'pry'

# Inspired by http://taylorluk.com/post/54982679495/how-to-test-rack-middleware-with-rspec

describe Houser::Middleware do
  let(:app) { ->(env) { [200, env, "app"] } }
  let(:options) do
    { 
      class_name: 'Account'
    }
  end

  let(:middleware) do
    Houser::Middleware.new(app, options)
  end

  let(:subdomain) { 'account1' }

  before do
    stub_const('Account', Class.new)
  end

  def env_for(url, opts={})
    opts.merge!('HTTP_HOST' => URI.parse(url).host)
    Rack::MockRequest.env_for(url, opts)
  end

  it "does nothing for non-subdomained requests" do
    expect(Account).to_not receive(:find_by)
    code, env = middleware.call(env_for("http://example.com"))
    expect(env['X-Houser-Subdomain']).to be_nil
    expect(env['X-Houser-ID']).to be_nil
  end

  it "sets X-HOUSER-ID header for known subdomains" do
    account = double(id: 1)
    expect(Account).to receive(:find_by).with(subdomain: subdomain).and_return(account)
    code, env = middleware.call(env_for("http://#{subdomain}.example.com"))
    expect(env['X-Houser-Subdomain']).to eq(subdomain)
    expect(env['X-Houser-ID']).to eq(1)
  end

  it "returns no headers for unknown subdomains" do
    expect(Account).to receive(:find_by).with(subdomain: subdomain).and_return(nil)
    code, env = middleware.call(env_for("http://#{subdomain}.example.com"))
    expect(env['X-Houser-Subdomain']).to be_nil
    expect(env['X-Houser-ID']).to be_nil
  end

  context "with more than one-level of TLD" do
    let(:options) do
      { 
        tld_length: 2,
        class_name: 'Account'
      }
    end

    it "supports more than one-level of TLD" do
      expect(Account).to_not receive(:find_by)
      code, env = middleware.call(env_for("http://example.co.uk"))
      expect(env['X-Houser-Subdomain']).to be_nil
      expect(env['X-Houser-ID']).to be_nil
    end
  end
end