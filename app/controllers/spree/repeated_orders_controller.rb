module Spree
  class RepeatedOrdersController < Spree::StoreController

    def create
      duplicated_order = Spree::Order.find(params[:id])
      new_order = current_order(true)

      new_line_items = []
      duplicated_order.line_items.each do |line_item|
        new_line_items << line_item.dup
      end

      new_order.line_items = new_line_items
      new_order.save

      redirect_to(cart_path)
    end

  end
end
