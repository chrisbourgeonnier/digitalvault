class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: [ :show ]
  after_action :verify_authorized, except: [ :index ]
  after_action :verify_policy_scoped, only: [ :index ]

  def index
    @orders = policy_scope(Order).order(created_at: :desc)
  end

  def show
    authorize @order
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end
end
