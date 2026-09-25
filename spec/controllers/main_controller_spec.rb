# frozen_string_literal: true

require "rails_helper"

RSpec.describe MainController, type: :controller do
  describe "GET #index" do
    let!(:rubrics) { create_list :rubric, 3 }
    let!(:articles) { create_list :article, 8, rubric: rubrics.first }

    before { get :index }

    context "required output per page" do
      it "render to index template" do
        is_expected.to render_template :index
      end

      it "instance var rubrics include only rubrics" do
        expect(assigns(:rubrics)).to match_array(rubrics)
      end

      it "instance var articles include only articles" do
        expect(assigns(:articles)).to match_array(articles)
      end
    end

    context "when rubric_id given" do
      let(:other_rubric) { rubrics.last }
      let!(:other_article) { create(:article, rubric: other_rubric) }

      before { get :index, params: { rubric_id: other_rubric.id } }

      it "instance var articles include only articles of the rubric" do
        expect(assigns(:articles)).to match_array([ other_article ])
      end
    end

    context "when q given" do
      let!(:found) { create(:article, title: "Уникальное событие дня", rubric: rubrics.first) }

      before { get :index, params: { q: "Уникальное" } }

      it "instance var articles include only matching articles" do
        expect(assigns(:articles)).to match_array([ found ])
      end
    end

    context "when there are more articles than one page" do
      let!(:articles) do
        Array.new(12) do |index|
          create(
            :article,
            title: format("Page article %02d", index),
            rubric: rubrics.first,
            created_at: Time.zone.local(2026, 1, 1) + index.hours
          )
        end
      end

      it "assigns the first ten articles" do
        expect(assigns(:articles).map(&:title)).to eq((2..11).map { |index| format("Page article %02d", index) }.reverse)
        expect(assigns(:has_more)).to be(true)
      end

      it "returns the next page without the layout" do
        get :index, params: { page: 2 }, xhr: true

        expect(response).to have_http_status(:ok)
        expect(assigns(:articles).map(&:title)).to eq([ "Page article 01", "Page article 00" ])
        expect(response.headers["X-Has-More"]).to eq("0")
      end
    end
  end
end
