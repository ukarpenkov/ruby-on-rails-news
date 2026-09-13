class AddRubricToArticles < ActiveRecord::Migration[8.1]
  def change
    add_reference :articles, :rubric, foreign_key: true

    reversible do |dir|
      dir.up do
        rubric_id = select_value("SELECT id FROM rubrics ORDER BY id ASC LIMIT 1")
        if rubric_id
          execute "UPDATE articles SET rubric_id = #{connection.quote(rubric_id)} WHERE rubric_id IS NULL"
        end

        change_column_null :articles, :rubric_id, false
      end
    end
  end
end
