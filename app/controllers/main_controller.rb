# frozen_string_literal: true

class MainController < ApplicationController
  ARTICLES_PER_PAGE = 10

  before_action :set_page_options

  def index
    @rubrics = Rubric.order(:id)
    @page = infinite_scroll_request? ? requested_page : 1
    scope = filtered_articles
    @articles = scope.includes(:rubric).offset((@page - 1) * ARTICLES_PER_PAGE).limit(ARTICLES_PER_PAGE)
    @has_more = scope.offset(@page * ARTICLES_PER_PAGE).pick(:id).present?

    return unless infinite_scroll_request?

    response.headers["X-Has-More"] = @has_more ? "1" : "0"
    render partial: "hit", collection: @articles, as: :article
  end

  private

  def filtered_articles
    articles = Article.order(created_at: :desc, id: :desc)
    articles = articles.by_rubric(params[:rubric_id]) if params[:rubric_id].present?
    articles = articles.search(params[:q]) if params[:q].present?
    articles
  end

  def infinite_scroll_request?
    request.xhr?
  end

  def requested_page
    page = params[:page].to_i
    page.positive? ? page : 1
  end

  def set_page_options
    @page_title = "News"
    @page_description = "Latest news"
    @page_keywords = "news articles"
  end
end
