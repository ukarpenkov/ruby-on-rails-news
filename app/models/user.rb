# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  has_many :favorites, dependent: :destroy
  has_many :favorite_articles, through: :favorites, source: :article

  validates :login, presence: true, uniqueness: true
  validates :password, length: { minimum: 4 }, allow_nil: true
end
