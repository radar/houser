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
    expect(Account).to_not receive(:where)
    code, env = middleware.call(env_for("http://example.com"))
    expect(env['Houser-Subdomain']).to be_nil
    expect(env['Houser-Object']).to be_nil
  end

  it "sets Houser-ID header for known subdomains" do
    account = double(id: 1)
    expect(Account).to receive(:where).with("subdomain" => subdomain).and_return([account])
    code, env = middleware.call(env_for("http://#{subdomain}.example.com"))
    expect(env['Houser-Subdomain']).to eq(subdomain)
    expect(env['Houser-Object']).to eq(account)
  end

  it "returns no headers for unknown subdomains" do
    expect(Account).to receive(:where).with("subdomain" => subdomain).and_return([])
    code, env = middleware.call(env_for("http://#{subdomain}.example.com"))
    expect(env['Houser-Subdomain']).to be_nil
    expect(env['Houser-Object']).to be_nil
  end


  context "double subdomain" do
    let(:subdomain) { 'ruby.melbourne' }

    it "sets Houser-ID header for known subdomains within subdomains" do
      account = double(id: 1)
      expect(Account).to receive(:where).with("subdomain" => subdomain).and_return([account])
      code, env = middleware.call(env_for("http://#{subdomain}.example.com"))
      expect(env['Houser-Subdomain']).to eq(subdomain)
      expect(env['Houser-Object']).to eq(account)
    end
  end

  context "with a different class name" do
    let(:options) do
      { 
        class_name: 'Store'
      }
    end

    let(:store) { double(id: 2) }

    before do
      stub_const('Store', Class.new)
    end

    it "calls the right class" do
      expect(Account).to_not receive(:where)
      expect(Store).to receive(:where).with("subdomain" => subdomain).and_return([store])
      code, env = middleware.call(env_for("http://#{subdomain}.example.com"))
      expect(env['Houser-Subdomain']).to eq(subdomain)
      expect(env['Houser-Object']).to eq(store)
    end
  end

  context "with more than one-level of TLD" do
    let(:options) do
      { 
        tld_length: 2,
        class_name: 'Account'
      }
    end

    it "supports more than one-level of TLD" do
      expect(Account).to_not receive(:where)
      code, env = middleware.call(env_for("http://example.co.uk"))
      expect(env['Houser-Subdomain']).to be_nil
      expect(env['Houser-ID']).to be_nil
    end

    context "double subdomain" do
      let(:subdomain) { 'ruby.melbourne' }

      it "sets Houser-ID header for known subdomains within subdomains" do
        account = double(id: 1)
        expect(Account).to receive(:where).with("subdomain" => subdomain).and_return([account])
        code, env = middleware.call(env_for("http://#{subdomain}.example.co.uk"))
        expect(env['Houser-Subdomain']).to eq(subdomain)
        expect(env['Houser-Object']).to eq(account)
      end
    end
  end

  context "with a different column name" do
    let(:options) do
      { 
        subdomain_column: 'foo',
        class_name: 'Account'
      }
    end

    it "finds by an alternative column" do
      account = double(id: 1)
      expect(Account).to receive(:where).with("foo" => subdomain).and_return([account])
      code, env = middleware.call(env_for("http://#{subdomain}.example.com"))
      expect(env['Houser-Subdomain']).to eq(subdomain)
      expect(env['Houser-Object']).to eq(account)
    end
  end
end