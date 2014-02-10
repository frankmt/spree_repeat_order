module Spree
  module Admin
    class RepeatedOrdersController < Spree::Admin::BaseController

      def create
        past_order = Spree::Order.find_by(number: params[:number])
        new_order = Spree::Order.new

        duplicate_order(past_order, new_order)

        if new_order.save
          flash[:success] = "The order has been duplicated. The new order id is #{new_order.number}"
        else
          flash[:error] = 'Oops.. something went wrong and the order could not be duplicated'
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
