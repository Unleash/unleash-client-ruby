require 'spec_helper'

RSpec.describe Unleash::Context do
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
        fancy: 'polarbear'
      }
    }
    context = Unleash::Context.new(params)
    expect(context.user_id).to eq('123')
    expect(context.session_id).to eq('verylongsesssionid')
    expect(context.remote_address).to eq('127.0.0.2')
    expect(context.properties).to eq({ fancy: 'polarbear' })
  end

  it "will ignore non hash properties" do
    params = {
      'properties' => [1, 2, 3]
    }
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
end
