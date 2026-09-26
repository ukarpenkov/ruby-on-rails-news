# frozen_string_literal: true

FactoryBot.define do
  factory :comment do
    association :user
    association :article
    body { "A short comment" }
  end
end
