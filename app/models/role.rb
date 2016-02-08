class Role < ActiveRecord::Base
  NAMES = %w(admin)

  has_many :users,
    inverse_of: :role,
    dependent: :nullify

  validates :name,
    presence: true,
    uniqueness: { case_sensitive: false }
end
