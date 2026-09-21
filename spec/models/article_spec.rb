# frozen_string_literal: true

require "rails_helper"

RSpec.describe Article, type: :model do
  it { should validate_presence_of :title }
  it { should validate_presence_of :body }
  it { should belong_to(:rubric) }
  it { should have_many(:favorites).dependent(:destroy) }

  describe ".search" do
    let!(:rubric) { create(:rubric) }
    let!(:found) { create(:article, title: "Football final", body: "Long story", rubric: rubric) }
    let!(:other) { create(:article, title: "Other news", body: "Nothing here", rubric: rubric) }

    it "finds articles by title" do
      expect(Article.search("Football")).to match_array([ found ])
    end

    it "finds articles by body" do
      expect(Article.search("Long")).to match_array([ found ])
    end

    it "is case insensitive" do
      expect(Article.search("football")).to match_array([ found ])
    end
  end
end
