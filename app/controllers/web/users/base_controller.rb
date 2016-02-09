module Web
  module Users
    class BaseController < Web::BaseController

      helper_method :resource_user

      protected

      def resource_user
        @resource_user ||= User.find params[:user_id]
      end

    end
  end
end
