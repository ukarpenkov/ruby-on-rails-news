# frozen_string_literal: true

require "rails_helper"

RSpec.describe UsersController, type: :controller do
  describe "GET #new" do
    before { get :new }

    it "render to new template" do
      is_expected.to render_template :new
    end

    it "instance var user is a new user" do
      expect(assigns(:user)).to be_a_new(User)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      let(:params) do
        { user: { login: "ivan", password: "1234", password_confirmation: "1234" } }
      end

      it "creates a user" do
        expect { post :create, params: params }.to change(User, :count).by(1)
      end

      it "stores user id in session" do
        post :create, params: params
        expect(session[:user_id]).to eq(User.find_by(login: "ivan").id)
      end

      it "redirects to root" do
        post :create, params: params
        is_expected.to redirect_to root_path
      end
    end

    context "when passwords do not match" do
      let(:params) do
        { user: { login: "ivan", password: "1234", password_confirmation: "abcd" } }
      end

      it "does not create a user" do
        expect { post :create, params: params }.not_to change(User, :count)
      end

      it "render to new template" do
        post :create, params: params
        is_expected.to render_template :new
      end
    end
  end
end
