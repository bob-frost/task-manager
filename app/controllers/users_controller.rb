class UsersController < ApplicationController
  helper_method :resource_user

  before_filter :require_no_user, only: [:new, :create]

  # GET /users/:id
  # GET /users/:id.json
  def show
    authorize resource_user, :show?
  end

  # GET /signup
  def new
    authorize resource_user, :create?
  end

  # POST /users
  # POST /users.json
  def create
    authorize resource_user, :create?

    if resource_user.save
      respond_to do |format|
        format.html do
          login resource_user
          flash[:success] = t '.success'
          redirect_to resource_user
        end
        format.json { render :show, status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new }
        format.json { render json: resource_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /users/:id/edit
  def edit
    authorize resource_user, :update?
  end

  # PATCH /users/:id
  # PATCH /users/:id.json
  def update
    authorize resource_user, :update?

    if resource_user.update_attributes resource_user_params
      respond_to do |format|
        format.html do
          flash[:success] = t '.success'
          redirect_to resource_user
        end
        format.json { render :show }
      end
    else
      respond_to do |format|
        format.html { render :edit }
        format.json { render json: resource_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/:id
  # DELETE /users/:id.json
  def destroy
    authorize resource_user, :destroy?

    resource_user.destroy
    respond_to do |format|
      format.html do
        flash[:success] = t '.success'
        redirect_to root_url
      end
      format.json { head :no_content }
    end
  end

  private

  def resource_user
    @user ||= if params[:id].present?
      User.find params[:id]
    else
      User.new resource_user_params
    end
  end

  def resource_user_params
    params.has_key?(:user) ? params.require(:user).permit(policy(:user).permitted_attributes) : {}
  end

end
