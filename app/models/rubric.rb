# frozen_string_literal: true

class Rubric < ApplicationRecord
  has_many :articles

  validates :title, presence: true
  validates :description, presence: true
end
