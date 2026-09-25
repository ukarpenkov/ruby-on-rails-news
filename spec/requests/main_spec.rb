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

    it "shows a guest avatar that leads to login" do
      get root_path

      expect(response.body).to include("avatar--guest")
      expect(response.body).to include(login_path)
    end

    it "shows a bookmark on each article" do
      get root_path

      expect(response.body).to include("bookmark")
      expect(response.body).to include(login_path)
    end

    it "shows the first ten articles and loads the next ten on scroll" do
      older = create(:article, title: "Staraya novost", rubric: rubric, created_at: 2.days.ago)
      newest = Array.new(10) do |index|
        create(:article, title: format("Svezhaya %02d", index), rubric: rubric, created_at: index.minutes.from_now)
      end

      get root_path

      newest.each { |item| expect(response.body).to include(item.title) }
      expect(response.body).not_to include(older.title)
      expect(response.body).to include('data-controller="infinite-scroll"')

      get root_path(page: 2), headers: { "X-Requested-With" => "XMLHttpRequest" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(older.title)
      expect(response.body).to include(article.title)
      newest.each { |item| expect(response.body).not_to include(item.title) }
      expect(response.headers["X-Has-More"]).to eq("0")
    end

    context "when signed in" do
      let!(:user) { create(:user, login: "ivan", password: "1234", password_confirmation: "1234") }

      before { post login_path, params: { login: "ivan", password: "1234" } }

      it "opens an account menu with favorites and logout" do
        get root_path

        expect(response.body).to include("avatar--user")
        expect(response.body).to include("Избранное")
        expect(response.body).to include(favorites_path)
        expect(response.body).to include("Выйти")
      end

      it "shows a bookmark that saves the article" do
        get root_path

        expect(response.body).to include(article_favorite_path(article))
      end
    end
  end
end
