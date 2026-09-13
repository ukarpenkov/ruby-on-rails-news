# frozen_string_literal: true

class Article < ApplicationRecord
  belongs_to :rubric

  validates :title, presence: true
  validates :body, presence: true
end
