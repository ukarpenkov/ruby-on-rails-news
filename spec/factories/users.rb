# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:login) { |n| "user#{n}" }
    password { "pass" }
    password_confirmation { "pass" }
  end
end
