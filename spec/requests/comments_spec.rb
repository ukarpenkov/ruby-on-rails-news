# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Comments", type: :request do
  let!(:user) { create(:user, login: "ivan", password: "1234", password_confirmation: "1234") }
  let!(:article) { create(:article, title: "Sbornaya vyigrala") }

  def sign_in
    post login_path, params: { login: "ivan", password: "1234" }
  end

  def comments_node(body)
    Nokogiri::HTML(body).at_css("#comments")
  end

  describe "GET /articles/:id" do
    it "embeds comment props for the React island and does not render the form" do
      create(:comment, article: article, user: user, body: 'He said "hi" & <b>bye</b>', created_at: 2.hours.ago)
      create(:comment, article: article, user: user, body: "Second", created_at: 1.hour.ago)
      create(:comment, body: "Other article")

      get article_path(article)

      node = comments_node(response.body)
      comments = JSON.parse(node["data-comments"])

      expect(response).to have_http_status(:ok)
      expect(node["data-comments-root"]).to eq("true")
      expect(node["data-signed-in"]).to eq("false")
      expect(node["data-create-url"]).to eq(article_comments_path(article))
      expect(node["data-login-url"]).to eq(login_path)
      expect(node.element_children).to be_empty
      expect(comments.map { |comment| comment["body"] }).to eq([ 'He said "hi" & <b>bye</b>', "Second" ])
      expect(comments.first["author"]).to eq("ivan")
    end

    it "marks the island as signed in" do
      sign_in

      get article_path(article)

      expect(comments_node(response.body)["data-signed-in"]).to eq("true")
    end
  end

  describe "POST /articles/:article_id/comments" do
    it "saves a comment for the signed-in user" do
      sign_in
      other = create(:user, login: "other")

      expect {
        post article_comments_path(article),
          params: { comment: { body: "  Hello  ", user_id: other.id } },
          as: :json
      }.to change(Comment, :count).by(1)

      comment = Comment.last
      json = JSON.parse(response.body)

      expect(response).to have_http_status(:created)
      expect(comment.user).to eq(user)
      expect(comment.article).to eq(article)
      expect(comment.body).to eq("Hello")
      expect(json).to include("id" => comment.id, "body" => "Hello", "author" => "ivan")
    end

    it "rejects a blank comment" do
      sign_in

      expect {
        post article_comments_path(article), params: { comment: { body: "   " } }, as: :json
      }.not_to change(Comment, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(JSON.parse(response.body)["error"]).to eq("Напишите комментарий")
    end

    it "answers 401 json when a guest posts" do
      expect {
        post article_comments_path(article), params: { comment: { body: "Hello" } }, as: :json
      }.not_to change(Comment, :count)

      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)["error"]).to eq("Войдите, чтобы продолжить")
    end

    it "redirects a guest html post to login" do
      post article_comments_path(article), params: { comment: { body: "Hello" } }

      expect(response).to redirect_to(login_path)
      expect(Comment.count).to eq(0)
    end
  end
end
