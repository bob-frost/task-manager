FactoryGirl.define do
  sequence :email do |n|
    "person-#{n}@example.com"
  end
  
  sequence :login do |n|
    "person-#{n}"
  end
end