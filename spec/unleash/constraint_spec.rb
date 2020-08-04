require "spec_helper"

RSpec.describe Unleash::Constraint do
  before do
    Unleash.configuration = Unleash::Configuration.new
    Unleash.logger = Unleash.configuration.logger
  end

  describe '#is_enabled?' do
    it 'matches based on property IN value' do
      context_params = {
        user_id: '123',
        session_id: 'verylongsesssionid',
        remote_address: '127.0.0.1',
        properties: {
          env: 'dev'
        }
      }
      context = Unleash::Context.new(context_params)
      constraint = Unleash::Constraint.new('env', 'IN', ['dev'])
      expect(constraint.matches_context?(context)).to be_truthy

      constraint = Unleash::Constraint.new('env', 'IN', ['dev', 'pre'])
      expect(constraint.matches_context?(context)).to be_truthy

      constraint = Unleash::Constraint.new('env', 'NOT_IN', ['dev', 'pre'])
      expect(constraint.matches_context?(context)).to be_falsey

      constraint = Unleash::Constraint.new('env', 'NOT_IN', ['pre', 'prod'])
      expect(constraint.matches_context?(context)).to be_truthy
    end

    it 'matches based on property NOT_IN value' do
      context_params = {
        user_id: '123',
        session_id: 'verylongsesssionid',
        remote_address: '127.0.0.2',
        properties: {
          env: 'dev'
        }
      }
      context = Unleash::Context.new(context_params)
      constraint = Unleash::Constraint.new('env', 'NOT_IN', ['dev'])
      expect(constraint.matches_context?(context)).to be_falsey

      constraint = Unleash::Constraint.new('env', 'NOT_IN', ['dev', 'pre'])
      expect(constraint.matches_context?(context)).to be_falsey

      constraint = Unleash::Constraint.new('env', 'NOT_IN', ['pre', 'prod'])
      expect(constraint.matches_context?(context)).to be_truthy
    end

    it 'matches based on user_id IN/NOT_IN user_id' do
      context_params = {
        user_id: '123',
        session_id: 'verylongsesssionid',
        remote_address: '127.0.0.3',
        properties: {
          fancy: 'polarbear'
        }
      }
      context = Unleash::Context.new(context_params)
      constraint = Unleash::Constraint.new('user_id', 'IN', ['123', '456'])
      expect(constraint.matches_context?(context)).to be_truthy

      constraint = Unleash::Constraint.new('user_id', 'IN', ['456', '789'])
      expect(constraint.matches_context?(context)).to be_falsey

      constraint = Unleash::Constraint.new('user_id', 'NOT_IN', ['123', '456'])
      expect(constraint.matches_context?(context)).to be_falsey

      constraint = Unleash::Constraint.new('user_id', 'NOT_IN', ['456', '789'])
      expect(constraint.matches_context?(context)).to be_truthy
    end
  end
end
