class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :name, null: false
      t.integer :user_id, null: false
      t.integer :assignee_id
      t.integer :state, null: false, default: 5
      t.text :description

      t.timestamps null: false
    end
  end
end
