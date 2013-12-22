module Spree
  class RepeatedOrdersController < Spree::StoreController

    def create
      duplicated_order = Spree::Order.find_by(number: params[:number])
      new_order = current_order(true)

      new_line_items = []
      duplicated_order.line_items.each do |line_item|
        new_line_items << line_item.dup
      end

      new_order.line_items = new_line_items

      if new_order.save
        flash[:success] = 'We have added your past order items to the cart. Just proceed to checkout to complete it.'
      else
        flash[:error] = 'We are sorry, but we could not add your past items to the cart.'
      end

      redirect_to(cart_path)
    end

  end
end
