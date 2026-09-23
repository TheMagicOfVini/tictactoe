# frozen_string_literal: true

FactoryBot.define do
  factory :player do
    sequence(:name) { |n| "Player #{n}" }
    wins { Faker::Number.number(2) }
    losses { Faker::Number.number(2) }
    draws { Faker::Number.number(2) }
  end
end
