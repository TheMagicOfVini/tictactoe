# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Players API index and show', type: :request do
  let!(:bob) { Player.create!(name: 'Bob', wins: 1, losses: 2, draws: 3) }
  let!(:ann) { Player.create!(name: 'Ann', wins: 4, losses: 5, draws: 6) }

  describe 'GET /api/v1/players' do
    it 'returns 200 and every player as a JSON array' do
      get '/api/v1/players'

      expect(response).to have_http_status(200)
      expect(json).to be_an(Array)
      expect(json.size).to eq(2)
      expect(json).to all(include('id', 'name', 'wins', 'losses', 'draws'))
      expect(json).to include(
        a_hash_including('id' => bob.id, 'name' => 'Bob', 'wins' => 1, 'losses' => 2, 'draws' => 3),
        a_hash_including('id' => ann.id, 'name' => 'Ann', 'wins' => 4, 'losses' => 5, 'draws' => 6)
      )
    end

    it 'returns an empty array when there are no players' do
      Player.delete_all

      get '/api/v1/players'

      expect(response).to have_http_status(200)
      expect(json).to eq([])
    end
  end

  describe 'GET /api/v1/players/:id' do
    it 'returns 200 and the player' do
      get "/api/v1/players/#{bob.id}"

      expect(response).to have_http_status(200)
      expect(json).to include('id' => bob.id, 'name' => 'Bob', 'wins' => 1, 'losses' => 2, 'draws' => 3)
    end

    it 'raises RecordNotFound for an unknown id, which Rails maps to 404' do
      # The test env sets show_exceptions = false, so the spec sees the exception itself.
      expect { get '/api/v1/players/999999' }.to raise_error(ActiveRecord::RecordNotFound)
      expect(ActionDispatch::ExceptionWrapper.rescue_responses['ActiveRecord::RecordNotFound']).to eq(:not_found)
    end
  end
end
