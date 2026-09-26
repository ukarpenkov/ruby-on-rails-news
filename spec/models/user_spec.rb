# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  subject { build(:user) }

  it { should validate_presence_of :login }
  it { should validate_uniqueness_of :login }
  it { should have_secure_password }
  it { should have_many(:comments).dependent(:destroy) }
  it { should have_many(:favorites).dependent(:destroy) }
  it { should have_many(:favorite_articles).through(:favorites) }
  it { should validate_length_of(:password).is_at_least(4) }

  it "authenticates with the right password" do
    user = create(:user, password: "1234", password_confirmation: "1234")

    expect(user.authenticate("1234")).to eq(user)
    expect(user.authenticate("wrong")).to be_falsey
  end

  it "does not store the raw password" do
    user = create(:user, password: "1234", password_confirmation: "1234")

    expect(user.password_digest).to be_present
    expect(user.password_digest).not_to eq("1234")
  end

  it "requires a password for a password account" do
    user = build(:user, password: nil, password_confirmation: nil)

    expect(user).not_to be_valid
  end

  it "creates a facebook account without a password" do
    auth = OmniAuth::AuthHash.new(provider: "facebook", uid: "42", info: { name: "Ivan Petrov" })

    user = User.from_omniauth(auth)

    expect(user).to be_persisted
    expect(user.login).to eq("Ivan_Petrov")
    expect(user.password_digest).to be_nil
    expect(User.from_omniauth(auth)).to eq(user)
  end

  it "adds a suffix when the facebook name is already taken" do
    create(:user, login: "Ivan_Petrov")
    auth = OmniAuth::AuthHash.new(provider: "facebook", uid: "42", info: { name: "Ivan Petrov" })

    expect(User.from_omniauth(auth).login).to eq("Ivan_Petrov_2")
  end
end
