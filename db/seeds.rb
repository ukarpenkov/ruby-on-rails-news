# frozen_string_literal: true

3.times do |i|
  Rubric.find_or_create_by!(title: "Rubric #{i + 1}") do |rubric|
    rubric.description = "News about rubric #{i + 1}."
  end
end

8.times do |i|
  Article.find_or_create_by!(title: "Article #{i + 1}") do |article|
    article.body = "This is the body of article #{i + 1}."
  end
end
