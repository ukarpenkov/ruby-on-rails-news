# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Article page", type: :request do
  describe "GET /articles/:id" do
    it "shows the article title and body" do
      rubric = create(:rubric, title: "Sport")
      article = create(
        :article,
        title: "Sbornaya vyigrala",
        body: "Gol na posledney minute.",
        rubric: rubric
      )

      get article_path(article)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Sbornaya vyigrala")
      expect(response.body).to include("Gol na posledney minute.")
      expect(response.body).to include("Sport")
    end

    it "shows a bookmark on the article" do
      article = create(:article)

      get article_path(article)

      expect(response.body).to include("bookmark")
    end
  end
end
