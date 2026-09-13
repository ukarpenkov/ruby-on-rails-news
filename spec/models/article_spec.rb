# frozen_string_literal: true

require "rails_helper"

RSpec.describe Article, type: :model do
  it { should validate_presence_of :title }
  it { should validate_presence_of :body }
  it { should belong_to(:rubric) }
end
