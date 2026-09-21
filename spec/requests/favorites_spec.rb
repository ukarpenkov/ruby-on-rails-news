# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Favorites", type: :request do
  let!(:user) { create(:user, login: "ivan", password: "1234", password_confirmation: "1234") }
  let!(:article) { create(:article, title: "Sbornaya vyigrala") }

  def sign_in
    post login_path, params: { login: "ivan", password: "1234" }
  end

  describe "GET /favorites" do
    it "redirects a guest to login" do
      get favorites_path

      expect(response).to redirect_to(login_path)
    end

    it "lists only the current user's saved articles" do
      create(:favorite, user: user, article: article)
      create(:article, title: "Drugoe sobytie")

      sign_in
      get favorites_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Sbornaya vyigrala")
      expect(response.body).not_to include("Drugoe sobytie")
    end
  end

  describe "POST /articles/:article_id/favorite" do
    it "saves the article for the signed-in user" do
      sign_in

      expect {
        post article_favorite_path(article)
      }.to change(Favorite, :count).by(1)

      expect(user.favorite_articles).to include(article)
    end

    it "replaces only the bookmark when requested as turbo stream" do
      sign_in

      post article_favorite_path(article), as: :turbo_stream

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq(Mime[:turbo_stream])
      expect(response.body).to include("Убрать из избранного")
      expect(response).not_to redirect_to(root_path)
    end
  end

  describe "DELETE /articles/:article_id/favorite" do
    it "removes the article from favorites" do
      create(:favorite, user: user, article: article)
      sign_in

      expect {
        delete article_favorite_path(article)
      }.to change(Favorite, :count).by(-1)
    end
  end
end
