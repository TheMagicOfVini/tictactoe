# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Players API destroy', type: :request do
  let!(:player) { Player.create!(name: 'Bob', wins: 1) }
  let(:admin_headers) { { 'X-Admin-Token' => AdminTokenHelper::ADMIN_TOKEN } }

  around { |example| with_admin_token(AdminTokenHelper::ADMIN_TOKEN) { example.run } }

  describe 'DELETE /api/v1/players/:id with a valid admin token' do
    it 'deletes the player and returns 204' do
      delete "/api/v1/players/#{player.id}", headers: admin_headers

      expect(response).to have_http_status(204)
      expect(Player.exists?(player.id)).to be(false)
    end
  end

  describe 'DELETE /api/v1/players/:id without a valid admin token' do
    it 'returns 401 without the header and keeps the player' do
      delete "/api/v1/players/#{player.id}"

      expect(response).to have_http_status(401)
      expect(json).to eq('error' => 'admin token required')
      expect(Player.exists?(player.id)).to be(true)
    end

    it 'returns 401 with a wrong token and keeps the player' do
      delete "/api/v1/players/#{player.id}", headers: { 'X-Admin-Token' => 'wrong' }

      expect(response).to have_http_status(401)
      expect(Player.exists?(player.id)).to be(true)
    end

    it 'returns 401, not 404, for an unknown id' do
      delete '/api/v1/players/999999'

      expect(response).to have_http_status(401)
    end

    [nil, '', '   '].each do |value|
      it "returns 401 with the header when ADMIN_TOKEN is #{value.inspect}" do
        with_admin_token(value) do
          delete "/api/v1/players/#{player.id}", headers: { 'X-Admin-Token' => value.to_s }
        end

        expect(response).to have_http_status(401)
        expect(Player.exists?(player.id)).to be(true)
      end
    end
  end
end
