module Web
  module Users
    class TasksController < Web::Users::BaseController

      helper_method :resource_collection

      def index; end

      private

      def resource_collection
        return @resource_collection if @resource_collection
        @resource_collection = if current_user && current_user.admin? && current_user == resource_user 
          Task.all
        else
          resource_user.associated_tasks
        end
        @resource_collection = @resource_collection.ordered.page(params[:page]).per(20)
      end

    end
  end
end
