module Rspec
  module AuthHelpers
    def login
      user = FactoryGirl.create :user
      login_as user    
    end

    def login_as_admin
      user = FactoryGirl.create :admin
      login_as user
    end

    def login_as(user)
      allow(controller).to receive(:current_user).and_return(user)
    end

    def logout
      allow(controller).to receive(:current_user).and_return(nil)
    end
  end
end
