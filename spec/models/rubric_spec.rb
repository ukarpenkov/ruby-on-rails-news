# frozen_string_literal: true

require "rails_helper"

RSpec.describe Rubric, type: :model do
  it { should validate_presence_of :title }
  it { should validate_presence_of :description }
  it { should have_many(:articles) }
end
