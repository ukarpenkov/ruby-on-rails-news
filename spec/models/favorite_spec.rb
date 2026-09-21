# frozen_string_literal: true

require "rails_helper"

RSpec.describe Favorite, type: :model do
  subject { create(:favorite) }

  it { should belong_to(:user) }
  it { should belong_to(:article) }
  it { should validate_uniqueness_of(:user_id).scoped_to(:article_id) }
end
