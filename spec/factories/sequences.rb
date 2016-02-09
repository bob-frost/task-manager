FactoryGirl.define do
  sequence :email do |n|
    "person-#{n}@example.com"
  end
  
  sequence :user_name do |n|
    "person-#{n}"
  end
end