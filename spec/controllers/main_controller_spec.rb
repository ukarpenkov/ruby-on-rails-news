# frozen_string_literal: true

require "rails_helper"

RSpec.describe MainController, type: :controller do
  describe "GET #index" do
    let!(:rubrics) { create_list :rubric, 3 }
    let!(:hits) { create_list :article, 8, rubric: rubrics.first }

    before { get :index }

    context "required output per page" do
      it "render to index template" do
        is_expected.to render_template :index
      end

      it "instance var rubrics include only rubrics" do
        expect(assigns(:rubrics)).to match_array(rubrics)
      end

      it "instance var hits include only articles" do
        expect(assigns(:hits)).to match_array(hits)
      end
    end
  end
end
