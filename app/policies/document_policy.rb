class DocumentPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.gestor?
        # Only documents linked to properties of companies managed by the user
        scope.joins(:property).where(properties: { company_id: user.company_ids })
      elsif user.inquilino?
        # Only documents where the occupant email matches the user email
        scope.joins(:occupant).where(occupants: { email: user.email })
      else
        scope.none
      end
    end
  end

  def index?
    user.admin? || user.gestor?
  end

  def show?
    user.admin? || (user.gestor? && user.company_ids.include?(record.property.company_id)) || (user.inquilino? && record.occupant.email == user.email)
  end

  def download_pdf?
    show?
  end

  def regenerate_pdf?
    update?
  end

  def create?
    user.admin? || user.gestor?
  end

  def update?
    user.admin? || (user.gestor? && user.company_ids.include?(record.property.company_id))
  end

  def destroy?
    user.admin? || (user.gestor? && user.company_ids.include?(record.property.company_id))
  end
end
