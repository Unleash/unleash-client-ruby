require 'unleash/context'

RSpec.describe Unleash::Context do
  before do
    Unleash.configuration = Unleash::Configuration.new
  end

  context 'parameters correctly assigned in initialization'

  it "when using snake_case" do
    params = {
      user_id: '123',
      session_id: 'verylongsesssionid',
      remote_address: '127.0.0.2',
      properties: {
        fancy: 'polarbear'
      }
    }
    context = Unleash::Context.new(params)
    expect(context.user_id).to eq('123')
    expect(context.session_id).to eq('verylongsesssionid')
    expect(context.remote_address).to eq('127.0.0.2')
    expect(context.properties).to eq({ fancy: 'polarbear' })
  end

  it "when using camelCase" do
    params = {
      'userId' => '123',
      'sessionId' => 'verylongsesssionid',
      'remoteAddress' => '127.0.0.2',
      'properties' => {
        'fancy' => 'polarbear'
      }
    }
    context = Unleash::Context.new(params)
    expect(context.user_id).to eq('123')
    expect(context.session_id).to eq('verylongsesssionid')
    expect(context.remote_address).to eq('127.0.0.2')
    expect(context.properties).to eq({ fancy: 'polarbear' })
  end

  it "will ignore non hash properties" do
    params = { 'properties' => [1, 2, 3] }
    context = Unleash::Context.new(params)
    expect(context.properties).to eq({})
  end

  it "will correctly use default values when using empty hash and client is not configured" do
    params = {}
    context = Unleash::Context.new(params)
    expect(context.app_name).to be_nil
    expect(context.environment).to eq('default')
  end

  it "will correctly use default values when using empty hash and client is configured" do
    Unleash.configure do |config|
      config.url         = 'http://testurl/api'
      config.app_name    = 'my_ruby_app'
      config.environment = 'dev'
    end

    params = {}
    context = Unleash::Context.new(params)
    expect(context.app_name).to eq('my_ruby_app')
    expect(context.environment).to eq('dev')
  end

  it "will correctly allow context config to overridde client configuration" do
    Unleash.configure do |config|
      config.url         = 'http://testurl/api'
      config.app_name    = 'my_ruby_app'
      config.environment = 'pre'
    end

    context = Unleash::Context.new(
      app_name: 'my_super_app',
      environment: 'test'
    )
    expect(context.app_name).to eq('my_super_app')
    expect(context.environment).to eq('test')
  end

  it "when using get_by_name with keys as symbols" do
    params = {
      userId: '123',
      session_id: 'verylongsesssionid',
      properties: {
        fancy: 'polarbear',
        countryCode: 'DK'
      }
    }
    context = Unleash::Context.new(params)
    expect(context.get_by_name('user_id')).to eq('123')
    expect(context.get_by_name(:user_id)).to eq('123')
    expect(context.get_by_name('userId')).to eq('123')
    expect(context.get_by_name('UserId')).to eq('123')
    expect(context.get_by_name('session_id')).to eq('verylongsesssionid')
    expect(context.get_by_name(:session_id)).to eq('verylongsesssionid')
    expect(context.get_by_name('sessionId')).to eq('verylongsesssionid')
    expect(context.get_by_name('SessionId')).to eq('verylongsesssionid')
    expect(context.get_by_name(:fancy)).to eq('polarbear')
    expect(context.get_by_name('fancy')).to eq('polarbear')
    expect(context.get_by_name('Fancy')).to eq('polarbear')
    expect(context.get_by_name('countryCode')).to eq('DK')
    expect(context.get_by_name(:countryCode)).to eq('DK')
    expect{ context.get_by_name(:country_code) }.to raise_error(KeyError)
    expect{ context.get_by_name('country_code') }.to raise_error(KeyError)
    expect{ context.get_by_name('CountryCode') }.to raise_error(KeyError)
    expect{ context.get_by_name(:CountryCode) }.to raise_error(KeyError)
  end

  it "when using get_by_name with keys as strings" do
    params = {
      'user_id' => '123',
      'sessionId' => 'verylongsesssionid',
      'properties' => {
        'fancy' => 'polarbear',
        'country_code' => 'UK'
      }
    }
    context = Unleash::Context.new(params)
    expect(context.get_by_name('user_id')).to eq('123')
    expect(context.get_by_name(:user_id)).to eq('123')
    expect(context.get_by_name('userId')).to eq('123')
    expect(context.get_by_name('UserId')).to eq('123')
    expect(context.get_by_name('session_id')).to eq('verylongsesssionid')
    expect(context.get_by_name(:session_id)).to eq('verylongsesssionid')
    expect(context.get_by_name('sessionId')).to eq('verylongsesssionid')
    expect(context.get_by_name('SessionId')).to eq('verylongsesssionid')
    expect(context.get_by_name(:fancy)).to eq('polarbear')
    expect(context.get_by_name('fancy')).to eq('polarbear')
    expect(context.get_by_name('Fancy')).to eq('polarbear')
    expect(context.get_by_name('country_code')).to eq('UK')
    expect(context.get_by_name(:country_code)).to eq('UK')
    expect(context.get_by_name('countryCode')).to eq('UK')
    expect(context.get_by_name(:countryCode)).to eq('UK')
    expect(context.get_by_name('CountryCode')).to eq('UK')
    expect(context.get_by_name(:CountryCode)).to eq('UK')
  end

  it "checks if property is included in the context" do
    params = {
      'user_id' => '123',
      'sessionId' => 'verylongsesssionid',
      'properties' => {
        'fancy' => 'polarbear',
        'country_code' => 'UK'
      }
    }
    context = Unleash::Context.new(params)
    expect(context.include?(:user_id)).to be true
    expect(context.include?(:user_name)).to be false
    expect(context.include?(:session_id)).to be true
    expect(context.include?(:fancy)).to be true
    expect(context.include?(:country_code)).to be true
    expect(context.include?(:countryCode)).to be true
    expect(context.include?(:CountryCode)).to be true
  end

  it "creates default date for current time if not populated" do
    params = {}
    context = Unleash::Context.new(params)

    expect(context.get_by_name(:CurrentTime)).not_to eq(nil)
  end

  it "creates doesn't create a default date if passed in" do
    date = DateTime.now
    params = {
      'currentTime': date
    }
    context = Unleash::Context.new(params)

    expect(context.get_by_name(:CurrentTime).to_s).to eq(date.to_s)
  end

  it "converts context to hash" do
    params = {
      app_name: 'my_ruby_app',
      environment: 'dev',
      user_id: '123',
      session_id: 'verylongsesssionid',
      remote_address: '127.0.0.2',
      current_time: '2023-03-22T00:00:00Z',
      properties: {
        fancy: 'polarbear'
      }
    }
    context = Unleash::Context.new(params)
    expect(context.to_h).to eq(params)
  end
end
