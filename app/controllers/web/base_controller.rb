module Web
  class BaseController < ApplicationController
    protect_from_forgery with: :exception

    layout 'web/layouts/application'

    rescue_from Pundit::NotAuthorizedError, with: :unauthorized

    helper_method :current_user

    def current_user
      return nil if cookies[:auth_token].blank?
      @current_user ||= User.find_by auth_token: cookies[:auth_token]
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
      flash[:error] = t :unauthorized
      redirect_to current_user || login_url
    end

    def require_no_user
      if current_user
        return redirect_to root_url
      end
    end
  end
end
