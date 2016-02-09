FactoryGirl.define do
  factory :user do
    email { FactoryGirl.generate :email }
    login { FactoryGirl.generate :login }
    password '12345'
    password_confirmation '12345'

    factory :admin do
      role { Role.find_by(name: 'admin') }
    end
  end
end
