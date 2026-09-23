# frozen_string_literal: true

require 'rails_helper'

# Test suite for the Item model
RSpec.describe Player, type: :model do
  before { @player = FactoryBot.build(:player) }

  subject { @player }
  it { should respond_to(:name) }
  it { should respond_to(:wins) }
  it { should respond_to(:losses) }
  it { should respond_to(:draws) }
  it { should be_valid }

  describe 'test no name' do
    it 'has no name' do
      FactoryBot.build(:player, name: nil).should_not be_valid
    end
  end

  # C11: unique names
  describe 'unique name' do
    it 'is not valid with the name of another player' do
      Player.create!(name: 'Ann')
      duplicate = Player.new(name: 'Ann')

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to include('has already been taken')
    end

    it 'has a unique index on name' do
      index = ActiveRecord::Base.connection.indexes(:players).find { |i| i.columns == ['name'] }

      expect(index).not_to be_nil
      expect(index.unique).to be(true)
    end

    it 'the database rejects a duplicate name' do
      Player.create!(name: 'Ann')

      expect { Player.new(name: 'Ann').save(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  # C13: case-sensitive names
  describe 'case of the name' do
    it 'treats names that differ in case as two players' do
      Player.create!(name: 'Alice')
      lower = Player.create!(name: 'alice')

      expect(lower).to be_persisted
      expect(Player.where(name: %w[Alice alice]).pluck(:name)).to contain_exactly('Alice', 'alice')
    end
  end
end
