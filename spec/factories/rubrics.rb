# frozen_string_literal: true

FactoryBot.define do
  factory :rubric do
    title { Faker::Book.genre }
    description { Faker::Lorem.sentence(word_count: 10) }
  end
end
