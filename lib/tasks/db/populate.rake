namespace :db do
  desc 'Populate database with fake data'
  task populate: :environment do
    require 'faker'

    users = []
    10.times do
      begin
        name                = Faker::Name.name
        transliterated_name = Russian.translit name
        email               = Faker::Internet.email transliterated_name
      end while name.length < 3 || name.length > 30 || User.exists?(email: email)

      users << User.create(name: name, email: email, password: '12345', password_confirmation: '12345')
    end

    100.times do |i|
      user        = users.sample
      assignee    = i % 5 == 0 ? nil : users.sample
      name        = Faker::Lorem.sentence
      state       = Task.states.keys.sample
      description = Faker::Lorem.paragraphs.join("\n\n")

      Task.create user: user, assignee: assignee, name: name, state: state, description: description
    end
  end
end
