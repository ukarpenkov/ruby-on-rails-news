# frozen_string_literal: true

class FavoritesController < ApplicationController
  before_action :require_login

  def index
    @articles = current_user.favorite_articles.includes(:rubric).order("favorites.created_at DESC")
    @page_title = "Избранное"
  end

  def create
    current_user.favorites.find_or_create_by!(article: article)
    redirect_back_or_to article_path(article), status: :see_other
  end

  def destroy
    current_user.favorites.find_by(article: article)&.destroy
    redirect_back_or_to article_path(article), status: :see_other
  end

  private

  def article
    @article ||= Article.find(params[:article_id])
  end
end
