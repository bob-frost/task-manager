class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :unauthorized

  helper_method :current_user

  def current_user
    return @current_user if @current_user
    auth_token = cookies[:auth_token] || request.headers[:Authentication]
    return nil if auth_token.blank? 
    @current_user = User.find_by auth_token: auth_token
  end

  protected

  def login(user, remember = false)
    if remember
      cookies.permanent[:auth_token] = user.auth_token
    else
      cookies[:auth_token] = user.auth_token
    end
  end

  def logout
    cookies.delete :auth_token
  end

  def unauthorized
    respond_to do |format|
      format.html do
        flash[:error] = t :unauthorized
        redirect_to current_user || login_url
      end
      format.json { render json: { error: 'Unauthorized' }, status: :unauthorized }
    end
  end

  def require_no_user
    if request.format.html? && current_user
      return redirect_to root_url
    end
  end

end
