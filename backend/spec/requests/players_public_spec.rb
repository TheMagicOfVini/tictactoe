# frozen_string_literal: true

require 'rails_helper'

# The read endpoints and the two POST endpoints need no admin token.
RSpec.describe 'Players API public endpoints', type: :request do
  let!(:player) { Player.create!(name: 'Bob') }
  let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }

  around { |example| with_admin_token(nil) { example.run } }

  it 'serves GET /api/v1/players' do
    get '/api/v1/players'

    expect(response).to have_http_status(200)
  end

  it 'serves GET /api/v1/players/:id' do
    get "/api/v1/players/#{player.id}"

    expect(response).to have_http_status(200)
  end

  it 'serves POST /api/v1/players' do
    post '/api/v1/players', params: { player: { name: 'Ann' } }.to_json, headers: headers

    expect(response).to have_http_status(201)
  end

  it 'serves POST /api/v1/players/results' do
    post '/api/v1/players/results', params: { name: 'Bob', result: 'win' }.to_json, headers: headers

    expect(response).to have_http_status(200)
  end
end
