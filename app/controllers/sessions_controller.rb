class SessionsController < ApplicationController
  before_filter :require_no_user, only: [:new, :create]
  
  # GET /login
  def new; end

  # POST /login
  # POST /login.json
  def create
    user = User.find_by email: params[:email]
    if user && user.authenticate(params[:password])
      respond_to do |format|
        format.html do
          login user, params[:remember] == '1'
          redirect_to user
        end
        format.json { render json: { auth_token: user.auth_token } }
      end
    else
      respond_to do |format|
        format.html do
          flash.now[:error] = t '.failure'
          render :new
        end
        format.json { render json: { error: 'Invalid email and/or password' }, status: :unauthorized }
      end
    end
  end

  # DELETE /logout
  def destroy
    logout
    redirect_to root_url
  end

end
