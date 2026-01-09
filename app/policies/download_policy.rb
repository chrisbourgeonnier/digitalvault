class DownloadPolicy < ApplicationPolicy
  # The record here is the Product being downloaded
  def show?
    return false unless user.present?

    # Check if user has a paid order containing this product
    user.orders.where(status: "paid").any? do |order|
      # cart_data is a hash like {"7" => 1, "9" => 2} where keys are product IDs
      cart_data = order.cart_data.is_a?(String) ? JSON.parse(order.cart_data) : order.cart_data
      cart_data.key?(record.id.to_s)
    end
  end
end
