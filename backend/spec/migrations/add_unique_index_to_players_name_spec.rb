# frozen_string_literal: true

require 'rails_helper'
require Rails.root.join('db/migrate/20260923000000_add_unique_index_to_players_name.rb')

# C12: the migration merges the players that have the same name
RSpec.describe AddUniqueIndexToPlayersName do
  let(:migration) { described_class.new }

  def unique_name_index
    ActiveRecord::Base.connection.indexes(:players).find { |i| i.columns == ['name'] && i.unique }
  end

  # SQLite runs the DDL in the test transaction, so the rollback restores the index
  it 'merges duplicate names into the row with the lowest id and adds the unique index' do
    ActiveRecord::Migration.suppress_messages { migration.down }
    expect(unique_name_index).to be_nil

    first = Player.new(name: 'Ann', wins: 1, losses: 2, draws: 3)
    first.save!(validate: false)
    Player.new(name: 'Ann', wins: 4, losses: 5, draws: 6).save!(validate: false)
    bob = Player.create!(name: 'Bob', wins: 1, losses: 0, draws: 0)

    ActiveRecord::Migration.suppress_messages { migration.up }

    anns = Player.where(name: 'Ann').to_a
    expect(anns.size).to eq(1)
    expect(anns.first.id).to eq(first.id)
    expect(anns.first.attributes).to include('wins' => 5, 'losses' => 7, 'draws' => 9)
    expect(bob.reload.attributes).to include('name' => 'Bob', 'wins' => 1, 'losses' => 0, 'draws' => 0)
    expect(unique_name_index).not_to be_nil
  end
end
