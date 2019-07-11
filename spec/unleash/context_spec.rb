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
    expect(context.properties).to eq({fancy: 'polarbear'})
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
    expect(context.properties).to eq({fancy: 'polarbear'})
  end

  it "fails with non hash properties" do
    params = {
      'properties' => [1,2,3]
    }
    context = Unleash::Context.new(params)
    expect(context.properties).to eq({})
  end
end
