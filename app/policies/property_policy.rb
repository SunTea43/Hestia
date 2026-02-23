class PropertyPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.gestor?
        scope.where(company_id: user.company_ids)
      else
        scope.none
      end
    end
  end

  def index?
    user.admin? || user.gestor?
  end

  def show?
    user.admin? || user.gestor? || user.contracts.exists?(property_id: record.id)
  end

  def create?
    user.admin? || user.gestor?
  end

  def update?
    user.admin? || (user.gestor? && user.company_ids.include?(record.company_id))
  end

  def destroy?
    user.admin? || (user.gestor? && user.company_ids.include?(record.company_id))
  end
end
