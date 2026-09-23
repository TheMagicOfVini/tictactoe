# frozen_string_literal: true

require 'rails_helper'

# C12: a second db:seed makes no duplicate player
RSpec.describe 'db/seeds.rb' do
  it 'makes no duplicate player when it runs two times' do
    2.times { load Rails.root.join('db/seeds.rb') }

    expect(Player.count).to eq(5)
    expect(Player.group(:name).having('COUNT(*) > 1').count).to be_empty
  end
end
