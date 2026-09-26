# frozen_string_literal: true

require "rails_helper"

RSpec.describe Comment, type: :model do
  subject { build(:comment) }

  it { should belong_to(:user) }
  it { should belong_to(:article) }
  it { should validate_presence_of(:body) }

  it "strips spaces around the text" do
    comment = create(:comment, body: "  hello  ")

    expect(comment.body).to eq("hello")
  end

  it "builds the same shape the React island reads" do
    comment = create(:comment, user: create(:user, login: "ivan"), body: "Hello")

    expect(comment.to_props).to include(id: comment.id, body: "Hello", author: "ivan")
    expect(comment.to_props[:created_at]).to eq(comment.created_at.iso8601)
  end
end
