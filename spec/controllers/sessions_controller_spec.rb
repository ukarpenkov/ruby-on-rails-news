# frozen_string_literal: true

require "rails_helper"

RSpec.describe SessionsController, type: :controller do
  describe "GET #new" do
    before { get :new }

    it "render to new template" do
      is_expected.to render_template :new
    end
  end

  describe "POST #create" do
    let!(:user) { create(:user, login: "ivan", password: "1234", password_confirmation: "1234") }

    context "with valid credentials" do
      before { post :create, params: { login: "ivan", password: "1234" } }

      it "stores user id in session" do
        expect(session[:user_id]).to eq(user.id)
      end

      it "redirects to root" do
        is_expected.to redirect_to root_path
      end
    end

    context "with invalid credentials" do
      before { post :create, params: { login: "ivan", password: "wrong" } }

      it "does not store user id in session" do
        expect(session[:user_id]).to be_nil
      end

      it "render to new template" do
        is_expected.to render_template :new
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:user) { create(:user) }

    before do
      session[:user_id] = user.id
      delete :destroy
    end

    it "clears user id from session" do
      expect(session[:user_id]).to be_nil
    end

    it "redirects to root" do
      is_expected.to redirect_to root_path
    end
  end
end
