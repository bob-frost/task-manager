admin_attributes = { 
  email: 'admin@example.com',
  name: 'Admin',
  password: '12345',
  password_confirmation: '12345',
  role_id: Role.find_or_create_by(name: 'admin').id
}
unless User.exists?(email: admin_attributes[:email])
  User.create admin_attributes
end

user_attributes = { 
  email: 'user@example.com',
  name: 'John Doe',
  password: '12345',
  password_confirmation: '12345'
}
unless User.exists?(email: user_attributes[:email])
  User.create user_attributes
end
