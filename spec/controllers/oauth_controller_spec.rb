# frozen_string_literal: true

require "rails_helper"

RSpec.describe OauthController, type: :controller do
  describe "POST #facebook_unavailable" do
    before { post :facebook_unavailable }

    it "redirects to login" do
      is_expected.to redirect_to(login_path)
    end

    it "explains that facebook is not configured" do
      expect(flash[:alert]).to eq("Вход через Facebook ещё не настроен")
    end
  end
end
