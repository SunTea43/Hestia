class DocumentTypePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin? || user.gestor?
        scope.all
      else
        scope.none
      end
    end
  end

  def index?
    user.admin? || user.gestor?
  end

  def show?
    user.admin? || user.gestor?
  end

  def create?
    user.admin? || user.gestor?
  end

  def update?
    user.admin? || user.gestor?
  end

  def destroy?
    user.admin? || user.gestor?
  end
end
