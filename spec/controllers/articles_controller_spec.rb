# frozen_string_literal: true

require "rails_helper"

RSpec.describe ArticlesController, type: :controller do
  describe "GET #show" do
    let!(:article) { create :article }

    before { get :show, params: { id: article.id } }

    context "required output per page" do
      it "render to show template" do
        is_expected.to render_template :show
      end

      it "instance var article include only article" do
        expect(assigns(:article)).to eq(article)
      end
    end
  end
end
