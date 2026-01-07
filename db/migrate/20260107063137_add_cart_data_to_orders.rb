class AddCartDataToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :cart_data, :text
  end
end
