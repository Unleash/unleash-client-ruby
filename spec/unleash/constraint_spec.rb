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
      expect(constraint.matches_context?(context)).to be true

      constraint = Unleash::Constraint.new('env', 'IN', ['dev', 'pre'])
      expect(constraint.matches_context?(context)).to be true

      constraint = Unleash::Constraint.new('env', 'NOT_IN', ['dev', 'pre'])
      expect(constraint.matches_context?(context)).to be false

      constraint = Unleash::Constraint.new('env', 'NOT_IN', ['pre', 'prod'])
      expect(constraint.matches_context?(context)).to be true
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
      expect(constraint.matches_context?(context)).to be false

      constraint = Unleash::Constraint.new('env', 'NOT_IN', ['dev', 'pre'])
      expect(constraint.matches_context?(context)).to be false

      constraint = Unleash::Constraint.new('env', 'NOT_IN', ['pre', 'prod'])
      expect(constraint.matches_context?(context)).to be true
    end

    it 'matches based on a value NOT_IN in a not existing context field' do
      context_params = {
        properties: {
        }
      }
      context = Unleash::Context.new(context_params)
      constraint = Unleash::Constraint.new('env', 'NOT_IN', ['anything'])
      expect(constraint.matches_context?(context)).to be true
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
      expect(constraint.matches_context?(context)).to be true

      constraint = Unleash::Constraint.new('user_id', 'IN', ['456', '789'])
      expect(constraint.matches_context?(context)).to be false

      constraint = Unleash::Constraint.new('user_id', 'NOT_IN', ['123', '456'])
      expect(constraint.matches_context?(context)).to be false

      constraint = Unleash::Constraint.new('user_id', 'NOT_IN', ['456', '789'])
      expect(constraint.matches_context?(context)).to be true
    end

    it 'matches based on property STR_STARTS_WITH value' do
      context_params = {
        properties: {
          env: 'development'
        }
      }
      context = Unleash::Context.new(context_params)
      constraint = Unleash::Constraint.new('env', 'STR_STARTS_WITH', ['dev'])
      expect(constraint.matches_context?(context)).to be true

      constraint = Unleash::Constraint.new('env', 'STR_STARTS_WITH', ['development'])
      expect(constraint.matches_context?(context)).to be true

      constraint = Unleash::Constraint.new('env', 'STR_STARTS_WITH', ['ment'])
      expect(constraint.matches_context?(context)).to be false
    end

    it 'matches based on property STR_ENDS_WITH value' do
      context_params = {
        properties: {
          env: 'development'
        }
      }
      context = Unleash::Context.new(context_params)
      constraint = Unleash::Constraint.new('env', 'STR_ENDS_WITH', ['ment'])
      expect(constraint.matches_context?(context)).to be true

      constraint = Unleash::Constraint.new('env', 'STR_ENDS_WITH', ['development'])
      expect(constraint.matches_context?(context)).to be true

      constraint = Unleash::Constraint.new('env', 'STR_ENDS_WITH', ['dev'])
      expect(constraint.matches_context?(context)).to be false
    end

    it 'matches based on property STR_CONTAINS value' do
      context_params = {
        properties: {
          env: 'development'
        }
      }
      context = Unleash::Context.new(context_params)
      constraint = Unleash::Constraint.new('env', 'STR_CONTAINS', ['ment'])
      expect(constraint.matches_context?(context)).to be true

      constraint = Unleash::Constraint.new('env', 'STR_CONTAINS', ['dev'])
      expect(constraint.matches_context?(context)).to be true

      constraint = Unleash::Constraint.new('env', 'STR_CONTAINS', ['development'])
      expect(constraint.matches_context?(context)).to be true

      constraint = Unleash::Constraint.new('env', 'STR_CONTAINS', ['DEVELOPMENT'])
      expect(constraint.matches_context?(context)).to be false
    end

    it 'matches based on property NUM_EQ value' do
      context_params = {
        properties: {
          distance: '0.3'
        }
      }
      context = Unleash::Context.new(context_params)
      constraint = Unleash::Constraint.new('distance', 'NUM_EQ', '0.3')
      expect(constraint.matches_context?(context)).to be true

      constraint = Unleash::Constraint.new('distance', 'NUM_EQ', '0.2')
      expect(constraint.matches_context?(context)).to be false

      constraint = Unleash::Constraint.new('distance', 'NUM_EQ', (0.1 + 0.2).to_s)
      expect(constraint.matches_context?(context)).to be true
    end

    it 'matches based on property NUM_LT value' do
      context_params = {
        user_id: '123',
        session_id: 'verylongsesssionid',
        remote_address: '127.0.0.1',
        properties: {
          distance: '3.141'
        }
      }
      context = Unleash::Context.new(context_params)

      constraint = Unleash::Constraint.new('distance', 'NUM_LT', '2.718')
      expect(constraint.matches_context?(context)).to be false

      constraint = Unleash::Constraint.new('distance', 'NUM_LT', '3.141')
      expect(constraint.matches_context?(context)).to be false

      constraint = Unleash::Constraint.new('distance', 'NUM_LT', '6.282')
      expect(constraint.matches_context?(context)).to be true
    end

    it 'matches based on property NUM_LTE value' do
      context_params = {
        user_id: '123',
        session_id: 'verylongsesssionid',
        remote_address: '127.0.0.1',
        properties: {
          distance: '3.141'
        }
      }
      context = Unleash::Context.new(context_params)

      constraint = Unleash::Constraint.new('distance', 'NUM_LTE', '2.718')
      expect(constraint.matches_context?(context)).to be false

      constraint = Unleash::Constraint.new('distance', 'NUM_LTE', '3.141')
      expect(constraint.matches_context?(context)).to be true

      constraint = Unleash::Constraint.new('distance', 'NUM_LTE', '6.282')
      expect(constraint.matches_context?(context)).to be true
    end

    it 'matches based on property NUM_GT value' do
      context_params = {
        user_id: '123',
        session_id: 'verylongsesssionid',
        remote_address: '127.0.0.1',
        properties: {
          distance: '3.141'
        }
      }
      context = Unleash::Context.new(context_params)

      constraint = Unleash::Constraint.new('distance', 'NUM_GT', '2.718')
      expect(constraint.matches_context?(context)).to be true

      constraint = Unleash::Constraint.new('distance', 'NUM_GT', '3.141')
      expect(constraint.matches_context?(context)).to be false

      constraint = Unleash::Constraint.new('distance', 'NUM_GT', '6.282')
      expect(constraint.matches_context?(context)).to be false
    end

    it 'matches based on property NUM_GTE value' do
      context_params = {
        user_id: '123',
        session_id: 'verylongsesssionid',
        remote_address: '127.0.0.1',
        properties: {
          distance: '3.141'
        }
      }
      context = Unleash::Context.new(context_params)

      constraint = Unleash::Constraint.new('distance', 'NUM_GTE', '2.718')
      expect(constraint.matches_context?(context)).to be true

      constraint = Unleash::Constraint.new('distance', 'NUM_GTE', '3.141')
      expect(constraint.matches_context?(context)).to be true

      constraint = Unleash::Constraint.new('distance', 'NUM_GTE', '6.282')
      expect(constraint.matches_context?(context)).to be false
    end

    it 'matches based on property SEMVER_EQ value' do
      context_params = {
        user_id: '123',
        session_id: 'verylongsesssionid',
        remote_address: '127.0.0.1',
        properties: {
          env: '3.1.41-beta'
        }
      }
      context = Unleash::Context.new(context_params)

      constraint = Unleash::Constraint.new('env', 'SEMVER_EQ', '3.1.41-beta')
      expect(constraint.matches_context?(context)).to be true
    end

    it 'matches based on property SEMVER_GT value' do
      context_params = {
        user_id: '123',
        session_id: 'verylongsesssionid',
        remote_address: '127.0.0.1',
        properties: {
          env: '3.1.41-gamma'
        }
      }
      context = Unleash::Context.new(context_params)

      constraint = Unleash::Constraint.new('env', 'SEMVER_GT', '3.1.41-beta')
      expect(constraint.matches_context?(context)).to be true
    end

    it 'matches based on property SEMVER_LT value' do
      context_params = {
        user_id: '123',
        session_id: 'verylongsesssionid',
        remote_address: '127.0.0.1',
        properties: {
          env: '3.1.41-alpha'
        }
      }
      context = Unleash::Context.new(context_params)

      constraint = Unleash::Constraint.new('env', 'SEMVER_LT', '3.1.41-beta')
      expect(constraint.matches_context?(context)).to be true
    end

    it 'matches based on property DATE_AFTER value' do
      context_params = {
        user_id: '123',
        session_id: 'verylongsesssionid',
        remote_address: '127.0.0.1',
        currentTime: '2022-01-30T13:00:00.000Z'
      }
      context = Unleash::Context.new(context_params)

      constraint = Unleash::Constraint.new('currentTime', 'DATE_AFTER', '2022-01-29T13:00:00.000Z')
      expect(constraint.matches_context?(context)).to be true

      constraint = Unleash::Constraint.new('currentTime', 'DATE_AFTER', '2022-01-29T13:00:00Z')
      expect(constraint.matches_context?(context)).to be true

      constraint = Unleash::Constraint.new('currentTime', 'DATE_AFTER', '2022-01-29T13:00Z')
      expect(constraint.matches_context?(context)).to be true

      constraint = Unleash::Constraint.new('currentTime', 'DATE_AFTER', '2022-01-30T12:59:59.999999Z')
      expect(constraint.matches_context?(context)).to be true

      constraint = Unleash::Constraint.new('currentTime', 'DATE_AFTER', '2022-01-30T12:59:59.999Z')
      expect(constraint.matches_context?(context)).to be true

      constraint = Unleash::Constraint.new('currentTime', 'DATE_AFTER', '2022-01-30T12:59:59')
      expect(constraint.matches_context?(context)).to be true

      constraint = Unleash::Constraint.new('currentTime', 'DATE_AFTER', '2022-01-30T12:59')
      expect(constraint.matches_context?(context)).to be true

      constraint = Unleash::Constraint.new('currentTime', 'DATE_AFTER', '2022-01-30T13:00:00.000Z')
      expect(constraint.matches_context?(context)).to be false

      constraint = Unleash::Constraint.new('currentTime', 'DATE_AFTER', '2022-01-31T13:00:00.000Z')
      expect(constraint.matches_context?(context)).to be false
    end

    it 'matches based on property DATE_BEFORE value' do
      context_params = {
        user_id: '123',
        session_id: 'verylongsesssionid',
        remote_address: '127.0.0.1',
        currentTime: '2022-01-30T13:00:00.000Z'
      }
      context = Unleash::Context.new(context_params)

      constraint = Unleash::Constraint.new('currentTime', 'DATE_BEFORE', '2022-01-29T13:00:00.000Z')
      expect(constraint.matches_context?(context)).to be false

      constraint = Unleash::Constraint.new('currentTime', 'DATE_BEFORE', '2022-01-31T13:00:00.000Z')
      expect(constraint.matches_context?(context)).to be true
    end

    it 'matches based on case insensitive property when operator is uppercased' do
      context_params = {
        user_id: '123',
        session_id: 'verylongsesssionid',
        remote_address: '127.0.0.1',
        properties: {
          env: 'development'
        }
      }
      context = Unleash::Context.new(context_params)
      constraint = Unleash::Constraint.new('env', 'STR_STARTS_WITH', ['DEV'], case_insensitive: true)
      expect(constraint.matches_context?(context)).to be true

      constraint = Unleash::Constraint.new('env', 'STR_ENDS_WITH', ['MENT'], case_insensitive: true)
      expect(constraint.matches_context?(context)).to be true

      constraint = Unleash::Constraint.new('env', 'STR_CONTAINS', ['LOP'], case_insensitive: true)
      expect(constraint.matches_context?(context)).to be true
    end

    it 'matches based on case insensitive property when context is uppercased' do
      context_params = {
        user_id: '123',
        session_id: 'verylongsesssionid',
        remote_address: '127.0.0.1',
        properties: {
          env: 'DEVELOPMENT'
        }
      }
      context = Unleash::Context.new(context_params)
      constraint = Unleash::Constraint.new('env', 'STR_STARTS_WITH', ['dev'], case_insensitive: true)
      expect(constraint.matches_context?(context)).to be true

      constraint = Unleash::Constraint.new('env', 'STR_ENDS_WITH', ['ment'], case_insensitive: true)
      expect(constraint.matches_context?(context)).to be true

      constraint = Unleash::Constraint.new('env', 'STR_CONTAINS', ['lop'], case_insensitive: true)
      expect(constraint.matches_context?(context)).to be true
    end

    it 'matches based on inverted property' do
      context_params = {
        user_id: '123',
        session_id: 'verylongsesssionid',
        remote_address: '127.0.0.1',
        properties: {
          env: 'development'
        }
      }
      context = Unleash::Context.new(context_params)
      constraint = Unleash::Constraint.new('env', 'STR_STARTS_WITH', ['dev'], inverted: true)
      expect(constraint.matches_context?(context)).to be false

      constraint = Unleash::Constraint.new('env', 'STR_ENDS_WITH', ['ment'], inverted: true)
      expect(constraint.matches_context?(context)).to be false

      constraint = Unleash::Constraint.new('env', 'STR_CONTAINS', ['lop'], inverted: true)
      expect(constraint.matches_context?(context)).to be false
    end

    it 'gracefully handles invalid constraint operators' do
      context_params = {
        user_id: '123',
        session_id: 'verylongsesssionid',
        remote_address: '127.0.0.1',
        properties: {
          env: 'development'
        }
      }
      context = Unleash::Context.new(context_params)
      constraint = Unleash::Constraint.new('env', 'NOT_A_VALID_OPERATOR', 'dev', inverted: true)
      expect(constraint.matches_context?(context)).to be true

      constraint = Unleash::Constraint.new('env', 'NOT_A_VALID_OPERATOR', ['dev'], inverted: true)
      expect(constraint.matches_context?(context)).to be true

      constraint = Unleash::Constraint.new('env', 'NOT_A_VALID_OPERATOR', 'dev')
      expect(constraint.matches_context?(context)).to be false

      constraint = Unleash::Constraint.new('env', 'NOT_A_VALID_OPERATOR', ['dev'])
      expect(constraint.matches_context?(context)).to be false
    end

    it 'warns about constraint construction for invalid value types for operator' do
      array_constraints = ['STR_CONTAINS', 'STR_ENDS_WITH', 'STR_STARTS_WITH', 'IN', 'NOT_IN']

      array_constraints.each do |operator_name|
        expect(Unleash.logger).to receive(:warn).with("value is a String, operator is expecting an Array")
        Unleash::Constraint.new('env', operator_name, '')
      end

      string_constraints = ['NUM_EQ', 'NUM_GT', 'NUM_GTE', 'NUM_LT', 'NUM_LTE',
                            'DATE_AFTER', 'DATE_BEFORE', 'SEMVER_EQ', 'SEMVER_GT', 'SEMVER_LT']
      string_constraints.each do |operator_name|
        expect(Unleash.logger).to receive(:warn).with("value is an Array, operator is expecting a String")
        Unleash::Constraint.new('env', operator_name, [])
      end
    end
  end
end
