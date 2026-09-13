# frozen_string_literal: true

class MainController < ApplicationController
  before_action :set_page_options

  def index
    @rubrics = Rubric.limit(3)
    @hits = Article.includes(:rubric).limit(8)
  end

  def set_page_options
    @page_title = "News"
    @page_description = "Latest news"
    @page_keywords = "news articles"
  end
end
