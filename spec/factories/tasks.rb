FactoryGirl.define do
  factory :task do
    sequence(:name) { |n| "Task #{n}" }
    description 'Task description'
    association :user
  end
end
