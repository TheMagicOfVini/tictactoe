# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'CORS', type: :request do
  let(:test_default_origin) { 'http://localhost:3000' }

  # C6: an allowed origin gets Access-Control-Allow-Origin; another origin does not
  describe 'a simple request' do
    it 'allows the test default origin' do
      get '/api/v1/players', headers: { 'Origin' => test_default_origin }

      expect(response.headers['Access-Control-Allow-Origin']).to eq(test_default_origin)
    end

    it 'does not allow another origin' do
      get '/api/v1/players', headers: { 'Origin' => 'http://evil.example' }

      expect(response.headers['Access-Control-Allow-Origin']).to be_nil
    end
  end

  # C5: rack-cors allows GET, POST, PUT, PATCH, DELETE, OPTIONS and HEAD
  describe 'a preflight request' do
    it 'preflights DELETE, PUT and PATCH for the test default origin' do
      process :options, '/api/v1/players/1',
              headers: {
                'Origin' => test_default_origin,
                'Access-Control-Request-Method' => 'DELETE'
              }

      allowed_methods = response.headers['Access-Control-Allow-Methods']

      %w[GET POST PUT PATCH DELETE OPTIONS HEAD].each do |method|
        expect(allowed_methods).to include(method)
      end
    end
  end
end
