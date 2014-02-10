module Spree
  module Admin 
    class RepeatedOrdersController < Spree::Admin::BaseController

      def create
        past_order = Spree::Order.find_by(number: params[:number])
        new_order = Spree::Order.new

        duplicate_order(past_order, new_order)

        if new_order.save
          flash[:success] = 'We have added your past order items to the cart. Just proceed to checkout to complete it.'
        else
          flash[:error] = 'We are sorry, but we could not add your past items to the cart.'
        end

        redirect_to(admin_orders_path)
      end

      private

      def duplicate_order(past_order, new_order)
        new_line_items = []
        past_order.line_items.each do |line_item|
          new_line_items << line_item.dup
        end

        new_order.line_items = new_line_items

        new_ship_address = past_order.ship_address.dup
        new_order.ship_address = new_ship_address
        new_bill_address = past_order.bill_address.dup
        new_order.bill_address = new_bill_address
      end
     
    end
  end
end
