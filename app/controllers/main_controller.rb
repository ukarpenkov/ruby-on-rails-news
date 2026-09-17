# frozen_string_literal: true

class MainController < ApplicationController
  before_action :set_page_options

  def index
    @rubrics = Rubric.order(:id)
    @articles = filtered_articles
  end

  private

  def filtered_articles
    articles = Article.includes(:rubric).order(created_at: :desc, id: :desc)
    articles = articles.by_rubric(params[:rubric_id]) if params[:rubric_id].present?
    articles = articles.search(params[:q]) if params[:q].present?
    articles
  end

  def set_page_options
    @page_title = "News"
    @page_description = "Latest news"
    @page_keywords = "news articles"
  end
end
