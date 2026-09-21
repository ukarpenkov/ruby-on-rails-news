# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Sessions", type: :request do
  let!(:user) { create(:user, login: "ivan", password: "1234", password_confirmation: "1234") }

  describe "GET /login" do
    it "renders the login form" do
      get login_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Логин")
      expect(response.body).to include(signup_path)
    end
  end

  describe "POST /login" do
    it "signs in with a valid login and password" do
      post login_path, params: { login: "ivan", password: "1234" }

      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include("avatar--user")
      expect(response.body).to include("Избранное")
      expect(response.body).to include("Выйти")
    end

    it "rejects a wrong password" do
      post login_path, params: { login: "ivan", password: "wrong" }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Неверный логин или пароль")
    end
  end

  describe "DELETE /logout" do
    it "signs out" do
      post login_path, params: { login: "ivan", password: "1234" }
      delete logout_path

      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include("avatar--guest")
    end
  end
end
