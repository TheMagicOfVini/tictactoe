# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Players API update', type: :request do
  let!(:player) { Player.create!(name: 'Bob', wins: 1, losses: 2, draws: 3) }
  let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }

  def put_player(attributes)
    put "/api/v1/players/#{player.id}", params: { player: attributes }.to_json, headers: headers
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
        put '/api/v1/players', params: { player: { wins: 5 } }.to_json, headers: headers
      end.to raise_error(ActionController::RoutingError)
    end

    it 'has no top-level PlayersController' do
      expect { ::PlayersController }.to raise_error(NameError)
    end
  end
end
