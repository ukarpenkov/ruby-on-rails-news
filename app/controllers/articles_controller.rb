# frozen_string_literal: true

class ArticlesController < ApplicationController
  def show
    @article = Article.find(params[:id])
    @comments = @article.comments.includes(:user).order(:created_at, :id)
    @page_title = @article.title
  end
end
