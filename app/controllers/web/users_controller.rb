module Web
  class UsersController < BaseController
    helper_method :resource_user

    before_filter :require_no_user, only: [:new, :create]

    def show
      authorize resource_user, :show?
    end

    def new
      authorize :user, :create?
    end

    def create
      authorize :user, :create?

      resource_user.assign_attributes resource_user_params
      if resource_user.save
        login resource_user
        flash[:success] = t '.success'
        redirect_to user_tasks_url(resource_user)
      else
        render :new
      end
    end

    def edit
      authorize resource_user, :update?
    end

    def update
      authorize resource_user, :update?

      if resource_user.update_attributes resource_user_params
        flash[:success] = t '.success'
        redirect_to resource_user
      else
        render :edit
      end
    end

    def destroy
      authorize resource_user, :destroy?

      resource_user.destroy
      flash[:success] = t '.success'
      redirect_to root_url
    end

    private

    def resource_user
      @user ||= if params[:id].present?
        User.find params[:id]
      else
        User.new
      end
    end

    def resource_user_params
      params.has_key?(:user) ? params.require(:user).permit(policy(resource_user).permitted_attributes) : {}
    end
  end
end
