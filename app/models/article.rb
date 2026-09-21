# frozen_string_literal: true

class Article < ApplicationRecord
  belongs_to :rubric
  has_many :favorites, dependent: :destroy

  validates :title, presence: true
  validates :body, presence: true

  scope :by_rubric, ->(rubric_id) { where(rubric_id: rubric_id) }
  scope :search, ->(query) { where("title ILIKE :q OR body ILIKE :q", q: "%#{query}%") }
end
