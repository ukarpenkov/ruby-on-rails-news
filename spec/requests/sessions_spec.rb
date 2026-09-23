# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Sessions", type: :request do
  let!(:user) { create(:user, login: "ivan", password: "1234", password_confirmation: "1234") }

  describe "GET /login" do
    it "renders the login form" do
      get login_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Логин")
      expect(response.body).to include("Войти через Facebook")
      expect(response.body).to include('data-turbo="false"')
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

  describe "POST /auth/facebook" do
    it "creates a user and signs in" do
      expect {
        post "/auth/facebook"
        follow_redirect!
      }.to change(User, :count).by(1)

      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include("avatar--user")

      user = User.find_by!(provider: "facebook", uid: "10001")
      expect(user.login).to eq("Ivan_Petrov")
      expect(user.password_digest).to be_nil
    end

    it "signs in the same facebook user again" do
      post "/auth/facebook"
      follow_redirect!

      expect {
        post "/auth/facebook"
        follow_redirect!
      }.not_to change(User, :count)
    end

    it "returns to login when facebook declines" do
      OmniAuth.config.mock_auth[:facebook] = :invalid_credentials

      post "/auth/facebook"
      2.times { follow_redirect! }

      expect(response).to redirect_to(login_path)
      follow_redirect!
      expect(response.body).to include("Не удалось войти через Facebook")
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
