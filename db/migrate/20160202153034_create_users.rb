class CreateUsers < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.string :email, null: false
      t.string :login, null: false
      t.string :password_digest, null: false
      t.string :auth_token, null: false

      t.timestamps null: false
    end
    add_index :users, :email, unique: true
    add_index :users, :login, unique: true
    add_index :users, :auth_token, unique: true
  end

  def down
    drop_table :users
  end
end
