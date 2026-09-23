# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password validations: false

  has_many :favorites, dependent: :destroy
  has_many :favorite_articles, through: :favorites, source: :article

  validates :login, presence: true, uniqueness: true
  validates :password, presence: true, on: :create, if: :password_login?
  validates :password, confirmation: true, allow_blank: true
  validates :password, length: { minimum: 4 }, allow_nil: true
  validates :uid, uniqueness: { scope: :provider }, allow_nil: true

  def self.from_omniauth(auth)
    find_or_create_by!(provider: auth.provider, uid: auth.uid.to_s) do |user|
      user.login = available_login(auth.info&.name)
    end
  end

  def self.available_login(name)
    base = name.to_s.strip.gsub(/[^\p{L}\p{N}_]+/, "_").gsub(/\A_+|_+\z/, "")
    base = "facebook" if base.blank?
    base = base.first(40)

    candidate = base
    suffix = 2
    while exists?(login: candidate)
      candidate = "#{base}_#{suffix}"
      suffix += 1
    end
    candidate
  end
  private_class_method :available_login

  def password_login?
    provider.blank?
  end
end
