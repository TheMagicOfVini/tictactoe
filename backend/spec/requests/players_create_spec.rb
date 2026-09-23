# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Players API create', type: :request do
  let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }

  def post_player(attributes)
    post '/api/v1/players', params: { player: attributes }.to_json, headers: headers
  end

  describe 'POST /api/v1/players with valid params' do
    it 'returns 201, the player and a Location header' do
      expect { post_player(name: 'Ann', wins: 1, losses: 2, draws: 3) }.to change(Player, :count).by(1)

      player = Player.find_by!(name: 'Ann')
      expect(response).to have_http_status(201)
      expect(json).to include('id' => player.id, 'name' => 'Ann', 'wins' => 1, 'losses' => 2, 'draws' => 3)
      expect(response.headers['Location']).to eq(api_v1_player_url(player))
    end

    it 'creates the player with only a name' do
      post_player(name: 'Ann')

      expect(response).to have_http_status(201)
      expect(json).to include('name' => 'Ann')
    end
  end

  describe 'POST /api/v1/players with invalid params' do
    it 'returns 422 and the errors for a blank name, and creates no player' do
      expect { post_player(name: '', wins: 1) }.not_to change(Player, :count)

      expect(response).to have_http_status(422)
      expect(json['name']).to include("can't be blank")
    end

    it 'returns 422 and the errors for a missing name, and creates no player' do
      expect { post_player(wins: 1) }.not_to change(Player, :count)

      expect(response).to have_http_status(422)
      expect(json['name']).to include("can't be blank")
    end
  end
end
