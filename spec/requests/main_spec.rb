# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Main page", type: :request do
  describe "GET /" do
    let!(:rubric) { create(:rubric, title: "Sport") }
    let!(:article) { create(:article, title: "Sbornaya vyigrala", rubric: rubric) }

    it "shows one article title" do
      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Sbornaya vyigrala")
    end

    it "links from the list to the article page" do
      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(article_path(article))
    end

    it "links to the rubric filter" do
      get root_path

      expect(response.body).to include(root_path(rubric_id: rubric.id))
    end

    it "shows only articles of the chosen rubric" do
      other_rubric = create(:rubric, title: "Politics")
      create(:article, title: "Drugoe sobytie", rubric: other_rubric)

      get root_path(rubric_id: rubric.id)

      expect(response.body).to include("Sbornaya vyigrala")
      expect(response.body).not_to include("Drugoe sobytie")
    end

    it "shows only articles matching the search query" do
      create(:article, title: "Drugoe sobytie", rubric: rubric)

      get root_path(q: "Sbornaya")

      expect(response.body).to include("Sbornaya vyigrala")
      expect(response.body).not_to include("Drugoe sobytie")
    end

    it "renders the search form" do
      get root_path

      expect(response.body).to include('name="q"')
    end
  end
end
