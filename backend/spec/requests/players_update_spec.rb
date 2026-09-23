# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Players API update', type: :request do
  let!(:player) { Player.create!(name: 'Bob', wins: 1, losses: 2, draws: 3) }
  let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }
  let(:admin_headers) { headers.merge('X-Admin-Token' => AdminTokenHelper::ADMIN_TOKEN) }

  around { |example| with_admin_token(AdminTokenHelper::ADMIN_TOKEN) { example.run } }

  def put_player(attributes, request_headers = admin_headers)
    put "/api/v1/players/#{player.id}", params: { player: attributes }.to_json, headers: request_headers
  end

  describe 'PUT /api/v1/players/:id without a valid admin token' do
    it 'returns 401 without the header and does not change the player' do
      put_player({ wins: 9 }, headers)

      expect(response).to have_http_status(401)
      expect(json).to eq('error' => 'admin token required')
      expect(player.reload.wins).to eq(1)
    end

    it 'returns 401 with a wrong token and does not change the player' do
      put_player({ wins: 9 }, headers.merge('X-Admin-Token' => 'wrong'))

      expect(response).to have_http_status(401)
      expect(player.reload.wins).to eq(1)
    end

    it 'returns 401 for PATCH without the header' do
      patch "/api/v1/players/#{player.id}", params: { player: { wins: 9 } }.to_json, headers: headers

      expect(response).to have_http_status(401)
      expect(player.reload.wins).to eq(1)
    end

    it 'returns 401, not 404, for an unknown id' do
      put '/api/v1/players/999999', params: { player: { wins: 9 } }.to_json, headers: headers

      expect(response).to have_http_status(401)
    end

    [nil, '', '   '].each do |value|
      it "returns 401 with the header when ADMIN_TOKEN is #{value.inspect}" do
        with_admin_token(value) do
          put_player({ wins: 9 }, headers.merge('X-Admin-Token' => value.to_s))
        end

        expect(response).to have_http_status(401)
        expect(player.reload.wins).to eq(1)
      end
    end
  end

  describe 'PUT /api/v1/players/:id' do
    context 'with valid params' do
      before { put_player(wins: 2, losses: 3, draws: 4) }

      it 'returns 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns the saved player' do
        expect(json).to include('id' => player.id, 'name' => 'Bob', 'wins' => 2, 'losses' => 3, 'draws' => 4)
      end

      it 'persists the counters' do
        expect(player.reload.attributes).to include('wins' => 2, 'losses' => 3, 'draws' => 4)
      end
    end

    context 'with a blank name' do
      before { put_player(name: '', wins: 9) }

      it 'returns 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns the errors' do
        expect(json['name']).to include("can't be blank")
      end

      it 'does not change the player' do
        expect(player.reload.attributes).to include('name' => 'Bob', 'wins' => 1)
      end
    end

    context 'with the name of another player' do
      before do
        Player.create!(name: 'Ann')
        put_player(name: 'Ann', wins: 9)
      end

      it 'returns 422 and the uniqueness error, and does not change the player' do
        expect(response).to have_http_status(422)
        expect(json['name']).to eq(['has already been taken'])
        expect(player.reload.attributes).to include('name' => 'Bob', 'wins' => 1)
      end
    end

    context 'with params that are not permitted' do
      before { put_player(wins: 5, result: 'win', slug: 'bob') }

      it 'ignores them and saves the permitted params' do
        expect(response).to have_http_status(200)
        expect(json).not_to include('result', 'slug')
        expect(player.reload.wins).to eq(5)
      end
    end
  end

  describe 'POST /api/v1/players' do
    it 'ignores params that are not permitted' do
      post '/api/v1/players', params: { player: { name: 'Ann', wins: 1, result: 'win' } }.to_json, headers: headers

      expect(response).to have_http_status(201)
      expect(json).to include('name' => 'Ann', 'wins' => 1)
      expect(json).not_to include('result')
    end
  end

  describe 'PUT /api/v1/players without an id' do
    it 'has no route' do
      expect do
        put '/api/v1/players', params: { player: { wins: 5 } }.to_json, headers: admin_headers
      end.to raise_error(ActionController::RoutingError)
    end

    it 'has no top-level PlayersController' do
      expect { ::PlayersController }.to raise_error(NameError)
    end
  end
end
