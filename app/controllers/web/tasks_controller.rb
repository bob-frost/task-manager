module Web
  class TasksController < BaseController
    helper_method :resource_collection, :resource_task

    def index; end

    def show
      authorize resource_task, :show?
    end

    def new
      authorize :task, :create?
    end

    def create
      authorize :task, :create?

      resource_task.assign_attributes resource_task_params
      if resource_task.save
        flash[:success] = t '.success'
        redirect_to resource_task
      else
        render :new
      end
    end

    def edit
      authorize resource_task, :update?
    end

    def update
      authorize resource_task, :update?

      if resource_task.update_attributes resource_task_params
        flash[:success] = t '.success'
        redirect_to resource_task
      else
        render :edit
      end
    end

    def destroy
      authorize resource_task, :destroy?

      resource_task.destroy
      respond_to do |format|
        format.html do
          flash[:success] = t '.success'
          redirect_to user_tasks_url(current_user)
        end
        format.js { render }
      end
    end

    def next_state
      authorize resource_task, :next_state?

      resource_task.next_state!
      respond_to do |format|
        format.html { redirect_to resource_task }
        format.js { render }
      end
    end

    private

    def resource_collection
      @collection ||= Task.ordered.page(params[:page]).per(20)
    end

    def resource_task
      @task ||= if params[:id].present?
        Task.find params[:id]
      else
        Task.new user: current_user
      end
    end

    def resource_task_params
      params.has_key?(:task) ? params.require(:task).permit(policy(resource_task).permitted_attributes) : {}
    end
  end
end
