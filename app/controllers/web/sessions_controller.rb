module Web
  class SessionsController < BaseController
    before_filter :require_no_user, only: [:new, :create]
    
    def new; end

    def create
      user = User.find_by email: params[:email]
      if user && user.authenticate(params[:password])
        login user, params[:remember] == '1'
        redirect_to user_tasks_url(user)
      else
        flash.now[:error] = t '.failure'
        render :new
      end
    end

    def destroy
      logout
      redirect_to root_url
    end

  end

end
