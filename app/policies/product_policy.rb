class ProductPolicy < ApplicationPolicy
  # Anyone can view the product index (catalog)
  def index?
    true
  end

  # Anyone can view a single product
  def show?
    true
  end

  # Only logged-in users can create products
  def create?
    user.present?
  end

  # Alias for create - used by form helpers
  def new?
    create?
  end

  # Only the product owner can update their product
  def update?
    user.present? && record.user_id == user.id
  end

  # Alias for update - used by form helpers
  def edit?
    update?
  end

  # Only the product owner can destroy their product
  def destroy?
    user.present? && record.user_id == user.id
  end

  # Scope: users only see their own products in seller dashboard
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.present?
        scope.where(user_id: user.id)
      else
        scope.none
      end
    end
  end
end
