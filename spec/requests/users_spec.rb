# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users", type: :request do
  describe "GET /signup" do
    it "renders the signup form with password confirmation" do
      get signup_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("password_confirmation")
      expect(response.body).to include(login_path)
    end
  end

  describe "POST /signup" do
    it "creates a user and signs in" do
      expect {
        post signup_path, params: {
          user: { login: "ivan", password: "1234", password_confirmation: "1234" }
        }
      }.to change(User, :count).by(1)

      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include("avatar--user")
    end

    it "rejects a short password" do
      expect {
        post signup_path, params: {
          user: { login: "ivan", password: "123", password_confirmation: "123" }
        }
      }.not_to change(User, :count)
    end

    it "rejects mismatched passwords" do
      expect {
        post signup_path, params: {
          user: { login: "ivan", password: "1234", password_confirmation: "abcd" }
        }
      }.not_to change(User, :count)
    end
  end
end
