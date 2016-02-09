class AddAttachmentToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :attachment, :string
    add_column :tasks, :attachment_content_type, :string
  end
end
