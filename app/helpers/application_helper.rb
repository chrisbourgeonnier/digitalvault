module ApplicationHelper
  def cart_item_count
    session[:cart]&.values&.sum&.to_i || 0
  end
end
