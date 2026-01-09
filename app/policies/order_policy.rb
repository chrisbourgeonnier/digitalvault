class OrderPolicy < ApplicationPolicy
  # Users can only view their own orders index
  def index?
    user.present?
  end

  # Users can only view their own order details
  def show?
    user.present? && record.user_id == user.id
  end

  # Scope: users only see their own orders
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
