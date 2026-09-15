# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Main page", type: :request do
  describe "GET /" do
    it "shows one article title" do
      rubric = create(:rubric, title: "Sport")
      create(:article, title: "Sbornaya vyigrala", rubric: rubric)

      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Sbornaya vyigrala")
    end

    it "links from the list to the article page" do
      rubric = create(:rubric, title: "Sport")
      article = create(:article, title: "Sbornaya vyigrala", rubric: rubric)

      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(article_path(article))
    end
  end
end

