class AddFacebookToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :provider, :string
    add_column :users, :uid, :string
    change_column_null :users, :password_digest, true
    add_index :users, [ :provider, :uid ], unique: true
  end
end
