# frozen_string_literal: true

rubrics = 3.times.map do |i|
  Rubric.find_or_create_by!(title: "Rubric #{i + 1}") do |rubric|
    rubric.description = "News about rubric #{i + 1}."
  end
end

8.times do |i|
  article = Article.find_or_initialize_by(title: "Article #{i + 1}")
  article.body = "This is the body of article #{i + 1}."
  article.rubric = rubrics[i % rubrics.size]
  article.save!
end
