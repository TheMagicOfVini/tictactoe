# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Players API results', type: :request do
  let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }

  def post_result(body)
    post '/api/v1/players/results', params: body.to_json, headers: headers
  end

  def counters(player)
    player.reload.attributes.slice('wins', 'losses', 'draws')
  end

  describe 'POST /api/v1/players/results' do
    # C6: create or increment by the name in the body
    context 'with a new name' do
      {
        'win' => { 'wins' => 1, 'losses' => 0, 'draws' => 0 },
        'loss' => { 'wins' => 0, 'losses' => 1, 'draws' => 0 },
        'draw' => { 'wins' => 0, 'losses' => 0, 'draws' => 1 }
      }.each do |result, expected|
        it "creates a new player with 1 in the matching counter for a #{result}" do
          expect { post_result(name: 'Ann', result: result) }.to change(Player, :count).by(1)
          expect(counters(Player.find_by!(name: 'Ann'))).to eq(expected)
        end
      end
    end

    context 'with a known name' do
      let!(:player) { Player.create!(name: 'Bob', wins: 3, losses: 2, draws: 1) }

      it 'adds 1 to the matching counter of a known player and does not change the others' do
        expect { post_result(name: 'Bob', result: 'loss') }.not_to change(Player, :count)
        expect(counters(player)).to eq('wins' => 3, 'losses' => 3, 'draws' => 1)
      end

      # C9: the response
      it 'returns 200 and the saved player' do
        post_result(name: 'Bob', result: 'draw')

        expect(response).to have_http_status(200)
        player.reload
        expect(json).to include('id' => player.id, 'name' => 'Bob', 'wins' => player.wins,
                                'losses' => player.losses, 'draws' => 2)
      end

      # C7: two quick results both count
      it 'counts two results for a known player' do
        post_result(name: 'Bob', result: 'win')
        post_result(name: 'Bob', result: 'win')

        expect(player.reload.wins).to eq(5)
      end

      # C7: the increment is one SQL statement, not a read and a save
      it 'uses one atomic SQL update' do
        queries = []
        callback = ->(*, payload) { queries << payload[:sql] }
        ActiveSupport::Notifications.subscribed(callback, 'sql.active_record') do
          post_result(name: 'Bob', result: 'win')
        end

        updates = queries.grep(/\AUPDATE/)
        expect(updates.grep(/UPDATE "players" SET "wins" = COALESCE\("wins", 0\) \+ 1/).size).to eq(1)
        expect(updates.grep(/"wins" = (\?|\d)/)).to be_empty
        expect(player.reload.wins).to eq(4)
      end
    end

    it 'works for the name Dr. J / 2' do
      post_result(name: 'Dr. J / 2', result: 'win')
      post_result(name: 'Dr. J / 2', result: 'win')

      expect(response).to have_http_status(200)
      expect(json['name']).to eq('Dr. J / 2')
      expect(Player.where(name: 'Dr. J / 2').count).to eq(1)
      expect(Player.find_by!(name: 'Dr. J / 2').wins).to eq(2)
    end

    # C8: another request creates the same new name between the find and the insert
    context 'when another request creates the same name first' do
      def expect_one_zed_with_two_wins
        post_result(name: 'Zed', result: 'win')

        expect(response).to have_http_status(200)
        expect(Player.where(name: 'Zed').count).to eq(1)
        expect(Player.find_by!(name: 'Zed').wins).to eq(2)
        expect(json).to include('name' => 'Zed', 'wins' => 2)
      end

      it 'makes one row when the unique index raises RecordNotUnique' do
        allow(Player).to receive(:find_or_create_by!).and_wrap_original do |_original, *|
          Player.create!(name: 'Zed', wins: 1) # the other request
          Player.new(name: 'Zed').save!(validate: false) # raises ActiveRecord::RecordNotUnique
        end

        expect_one_zed_with_two_wins
      end

      it 'makes one row when the uniqueness validation raises RecordInvalid' do
        allow(Player).to receive(:find_or_create_by!).and_wrap_original do |_original, *|
          Player.create!(name: 'Zed', wins: 1) # the other request
          Player.create!(name: 'Zed') # raises ActiveRecord::RecordInvalid
        end

        expect_one_zed_with_two_wins
      end
    end

    # C10: invalid input changes nothing
    context 'with invalid input' do
      let!(:player) { Player.create!(name: 'Bob', wins: 3, losses: 2, draws: 1) }

      {
        'a result that is not win, loss or draw' => [{ name: 'Bob', result: 'tie' }, 'result'],
        'a missing result' => [{ name: 'Bob' }, 'result'],
        'an empty name' => [{ name: '', result: 'win' }, 'name'],
        'a whitespace-only name' => [{ name: '   ', result: 'win' }, 'name'],
        'a missing name' => [{ result: 'win' }, 'name'],
        'a new name and a bad result' => [{ name: 'Ann', result: 'tie' }, 'result']
      }.each do |description, (body, key)|
        it "returns 422 and the errors for #{description}, and changes nothing" do
          expect { post_result(body) }.not_to change(Player, :count)

          expect(response).to have_http_status(422)
          expect(json[key]).to be_present
          expect(counters(player)).to eq('wins' => 3, 'losses' => 2, 'draws' => 1)
        end
      end
    end

    # C13: exact, case-sensitive match
    context 'with a name that differs only in case' do
      let!(:player) { Player.create!(name: 'Alice', wins: 3) }

      it 'creates a second player and does not change the first' do
        post_result(name: 'alice', result: 'win')

        expect(json).to include('name' => 'alice', 'wins' => 1)
        expect(Player.find_by!(name: 'alice').wins).to eq(1)
        expect(player.reload.wins).to eq(3)
      end

      it 'keeps the case of the name' do
        post_result(name: 'Alice', result: 'win')

        expect(json).to include('id' => player.id, 'name' => 'Alice', 'wins' => 4)
      end
    end
  end

  # C11: the old create endpoint rejects a known name
  describe 'POST /api/v1/players with a known name' do
    it 'returns 422' do
      Player.create!(name: 'Ann')
      post '/api/v1/players', params: { player: { name: 'Ann', wins: 1 } }.to_json, headers: headers

      expect(response).to have_http_status(422)
      expect(json['name']).to include('has already been taken')
      expect(Player.where(name: 'Ann').count).to eq(1)
    end
  end
end
