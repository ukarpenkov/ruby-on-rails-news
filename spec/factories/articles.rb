# frozen_string_literal: true

FactoryBot.define do
  factory :article do
    title { Faker::Lorem.sentence(word_count: 5) }
    body { Faker::Lorem.paragraph }
  end
end
