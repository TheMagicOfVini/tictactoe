# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/cors_origins'

RSpec.describe CorsOrigins do
  describe '.parse' do
    # C1: trims spaces and drops empty entries
    it 'trims spaces and drops empty entries' do
      expect(described_class.parse(' http://a.com , ,http://b.com ')).to eq(
        ['http://a.com', 'http://b.com']
      )
    end

    it 'returns an empty list for nil' do
      expect(described_class.parse(nil)).to eq([])
    end
  end

  describe '.list' do
    # C1: returns the origins from CORS_ORIGINS
    %w[development test production].each do |rails_env|
      it "returns the origins from CORS_ORIGINS for #{rails_env}" do
        env = { 'CORS_ORIGINS' => 'http://a.com, http://b.com' }

        expect(described_class.list(env, rails_env)).to eq(['http://a.com', 'http://b.com'])
      end
    end

    # C2: development and test default to http://localhost:3000
    it 'returns the default origin for development when CORS_ORIGINS is not set' do
      expect(described_class.list({}, 'development')).to eq(['http://localhost:3000'])
    end

    it 'returns the default origin for test when CORS_ORIGINS is not set' do
      expect(described_class.list({}, 'test')).to eq(['http://localhost:3000'])
    end

    # C3: production requires CORS_ORIGINS
    it 'raises for production when CORS_ORIGINS is not set' do
      expect { described_class.list({}, 'production') }.to raise_error(
        CorsOrigins::MissingOriginsError,
        'CORS_ORIGINS must be set in production. Set it to a comma-separated list of allowed origins.'
      )
    end

    it 'raises for production when CORS_ORIGINS is blank' do
      env = { 'CORS_ORIGINS' => '  , ,' }

      expect { described_class.list(env, 'production') }.to raise_error(
        CorsOrigins::MissingOriginsError,
        'CORS_ORIGINS must be set in production. Set it to a comma-separated list of allowed origins.'
      )
    end

    it 'returns the origins for production when CORS_ORIGINS is set' do
      env = { 'CORS_ORIGINS' => 'https://example.com' }

      expect(described_class.list(env, 'production')).to eq(['https://example.com'])
    end

    # C4: the app never uses * as a default origin
    it 'the default origin is not *' do
      expect(described_class::DEFAULT_ORIGIN).not_to eq('*')
    end

    it 'a blank CORS_ORIGINS in development never returns *' do
      expect(described_class.list({}, 'development')).not_to include('*')
    end
  end
end
