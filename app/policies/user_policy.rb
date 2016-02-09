class UserPolicy < ApplicationPolicy

  def show?
    true
  end

  def create?
    true
  end

  def update?
    manage?
  end

  def destroy?
    manage?
  end

  def permitted_attributes
    attributes = [:email, :name, :password, :password_confirmation]
    attributes << :role_id if user.present? && user.admin? && user != record
    attributes
  end

  private

  def manage?
    user.present? && (user.admin? || user == record)
  end
end
