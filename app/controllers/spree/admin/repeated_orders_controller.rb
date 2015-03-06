module Spree
  module Admin
    class RepeatedOrdersController < Spree::Admin::BaseController

      include Spree::SpreeRepeatedOrder::ControllerHelpers::RepeatedOrder

      def create
        past_order = Spree::Order.find_by(number: params[:number])
        new_order = Spree::Order.new

        duplicate_order(past_order, new_order)
        duplicate_address(past_order, new_order)

        last_incomplete_order = new_order.user.last_incomplete_spree_order

        success = true
        success = success && !past_order.completed_at.blank?
        success = success && new_order.generate_order_number #forcing number generation since we are skipping validation
        success = success && new_order.save(validate: false)
        success = success && merge_with_current_order(new_order, last_incomplete_order)

        if success
          flash[:success] = "The order has been duplicated. The new order id is #{new_order.number}"
          redirect_to(admin_orders_path)
        else
          flash[:error] = 'Oops.. something went wrong and the order could not be duplicated'
          redirect_to(edit_admin_order_path(past_order.number))
        end

      end

      private

      def merge_with_current_order(new_order, last_incomplete_order)
        if last_incomplete_order
          new_order.merge!(last_incomplete_order, new_order.user)
          new_order.save(validate: false)
        else
          true
        end
      end

      def duplicate_address(past_order, new_order)
        new_order.email = past_order.email
        new_order.user = past_order.user

        new_ship_address = past_order.ship_address.dup
        new_order.ship_address = new_ship_address
        new_bill_address = past_order.bill_address.dup
        new_order.bill_address = new_bill_address

        duplicate_extension(past_order, new_order)
      end

      def duplicate_extension(past_order, new_order)
        #do nothing - only here so it can be overriden
      end

    end
  end
end
