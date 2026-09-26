# frozen_string_literal: true

class CommentsController < ApplicationController
  before_action :require_login

  def create
    comment = article.comments.build(comment_params)
    comment.user = current_user

    if comment.save
      render json: comment.to_props, status: :created
    else
      render json: { error: "Напишите комментарий" }, status: :unprocessable_content
    end
  end

  private

  def article
    @article ||= Article.find(params[:article_id])
  end

  def comment_params
    params.expect(comment: [ :body ])
  end
end
