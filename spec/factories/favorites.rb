# frozen_string_literal: true

FactoryBot.define do
  factory :favorite do
    association :user
    association :article
  end
end
