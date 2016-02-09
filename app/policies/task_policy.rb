class TaskPolicy < ApplicationPolicy

  def show?
    true
  end

  def create?
    user.present?
  end

  def update?
    manage?
  end

  def destroy?
    manage?
  end

  def next_state?
    manage? || (user.present? && record.assignee == user)
  end

  def permitted_attributes
    [:name, :description, :assignee_id, :attachment]
  end

  private

  def manage?
    user.present? && (user.admin? || user == record.user)
  end
end
