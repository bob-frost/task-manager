class Task < ActiveRecord::Base
  belongs_to :user

  belongs_to :assignee, class_name: 'User'

  validates :name, presence: true

  validates :user, presence: true

  enum state: {
    todo: 5,
    started: 10,
    finished: 15
  }

  include AASM
  aasm column: :state, enum: true, skip_validation_on_save: true do
    state :todo, :initial => true
    state :started
    state :finished

    event :next_state do
      transitions from: :todo, to: :started
      transitions from: :started, to: :finished
      transitions from: :finished, to: :todo
    end
  end

  mount_uploader :attachment, Task::AttachmentUploader
  validates :attachment, max_file_size: 2.megabytes

  scope :ordered, -> { order('created_at DESC') }
end
