# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  subject { build(:user) }

  it { should validate_presence_of :login }
  it { should validate_uniqueness_of :login }
  it { should have_secure_password }
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
end
