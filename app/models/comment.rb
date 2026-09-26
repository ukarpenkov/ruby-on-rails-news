# frozen_string_literal: true

class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :article

  validates :body, presence: true

  before_validation :strip_body

  def to_props
    {
      id: id,
      body: body,
      author: user.login,
      created_at: created_at.iso8601
    }
  end

  private

  def strip_body
    self.body = body.to_s.strip
  end
end
