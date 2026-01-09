class OrdersController < ApplicationController
  before_action :authenticate_user!

  def index
    # Show only current user's orders, newest first
    @orders = current_user.orders.order(created_at: :desc)
  end

  def show
    # Find order belonging to current user
    @order = current_user.orders.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to orders_path, alert: "Order not found."
  end
end
