class CreateFavorites < ActiveRecord::Migration[8.1]
  def change
    create_table :favorites do |t|
      t.references :user, null: false, foreign_key: true, index: false
      t.references :article, null: false, foreign_key: true

      t.timestamps
    end
    add_index :favorites, [ :user_id, :article_id ], unique: true
  end
end
