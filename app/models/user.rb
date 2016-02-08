class User < ActiveRecord::Base
  has_secure_password

  belongs_to :role

  validates :email,
    presence: true,
    uniqueness: { case_sensitive: false },
    email: true

  validates :login,
    presence: true,
    length: { within: 3..10 },
    uniqueness: { case_sensitive: false }

  validates :password,
    length: { within: 4..20 },
    allow_blank: :true

  before_create :generate_auth_token

  class << self
    def new_token(column)
      begin
        token = SecureRandom.urlsafe_base64
      end while User.exists?(column => token)
      token
    end
  end

  def has_role?(role_name)
    role.present? && role.name == role_name.to_s
  end

  # def admin?
  Role::NAMES.each do |role_name|
    define_method "#{role_name}?" do
      has_role? role_name
    end
  end

  private

  def generate_auth_token
    self.auth_token = self.class.new_token :auth_token
  end
    
end
