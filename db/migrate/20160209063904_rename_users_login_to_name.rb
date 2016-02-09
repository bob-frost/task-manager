class RenameUsersLoginToName < ActiveRecord::Migration
  def up
    rename_column :users, :login, :name
  end

  def down
    rename_column :users, :name, :login
  end
end
