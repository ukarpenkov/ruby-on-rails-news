# frozen_string_literal: true

require "rails_helper"

RSpec.describe FavoritesController, type: :controller do
  let!(:user) { create(:user) }
  let!(:article) { create(:article) }

  describe "GET #index" do
    context "when guest" do
      before { get :index }

      it "redirects to login" do
        is_expected.to redirect_to login_path
      end
    end

    context "when signed in" do
      let!(:favorite) { create(:favorite, user: user, article: article) }
      let!(:other) { create(:article) }

      before do
        session[:user_id] = user.id
        get :index
      end

      it "render to index template" do
        is_expected.to render_template :index
      end

      it "instance var articles include only favorite articles" do
        expect(assigns(:articles)).to match_array([ article ])
      end
    end
  end

  describe "POST #create" do
    context "when guest" do
      it "does not create a favorite" do
        expect {
          post :create, params: { article_id: article.id }
        }.not_to change(Favorite, :count)
      end

      it "redirects to login" do
        post :create, params: { article_id: article.id }
        is_expected.to redirect_to login_path
      end
    end

    context "when signed in" do
      before { session[:user_id] = user.id }

      it "creates a favorite" do
        expect {
          post :create, params: { article_id: article.id }
        }.to change(Favorite, :count).by(1)
      end

      it "does not create a duplicate favorite" do
        create(:favorite, user: user, article: article)

        expect {
          post :create, params: { article_id: article.id }
        }.not_to change(Favorite, :count)
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:favorite) { create(:favorite, user: user, article: article) }

    context "when signed in" do
      before { session[:user_id] = user.id }

      it "destroys the favorite" do
        expect {
          delete :destroy, params: { article_id: article.id }
        }.to change(Favorite, :count).by(-1)
      end

      it "does not destroy another user's favorite" do
        other_user = create(:user)
        other_article = create(:article)
        create(:favorite, user: other_user, article: other_article)

        expect {
          delete :destroy, params: { article_id: other_article.id }
        }.not_to change(Favorite, :count)
      end
    end
  end
end
