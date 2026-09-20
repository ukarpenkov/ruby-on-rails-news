# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  validates :login, presence: true, uniqueness: true
  validates :password, length: { minimum: 4 }, allow_nil: true
end
