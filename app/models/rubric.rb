# frozen_string_literal: true

class Rubric < ApplicationRecord
  validates :title, presence: true
  validates :description, presence: true
end
