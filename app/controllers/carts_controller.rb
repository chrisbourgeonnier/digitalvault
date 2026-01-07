class CartsController < ApplicationController
  def show
    session[:cart] ||= {}  # Initialize empty cart hash if nil
    @line_items = build_line_items
  end

  def add_item
    product_id = params[:product_id]
    session[:cart] ||= {}
    session[:cart][product_id] ||= 0
    session[:cart][product_id] += 1
    redirect_to cart_path, notice: "Added to cart"
  end

  def remove_item
    product_id = params[:product_id]
    session[:cart].delete(product_id)
    redirect_to cart_path, notice: "Removed from cart"
  end

  def clear
    session[:cart] = {}
    redirect_to cart_path, notice: "Cart cleared"
  end

  private

  def build_line_items
    cart = session[:cart] || {}
    cart.keys.map do |product_id|
      product = Product.find_by(id: product_id)
      next unless product  # Skip deleted products
      { product: product, quantity: cart[product_id.to_s] }
    end.compact
  end
end
