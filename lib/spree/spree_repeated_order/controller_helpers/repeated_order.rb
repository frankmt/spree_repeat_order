module Spree
  module SpreeRepeatedOrder
    module ControllerHelpers
      module RepeatedOrder

        def duplicate_order(past_order, new_order)
          new_line_items = []
          past_order.line_items.each do |line_item|
            if (line_item.product && line_item.product.available? && !line_item.product.deleted?)
              new_line_item = line_item.dup
              new_line_item.reload_price
              new_line_items << new_line_item
            end
          end

          new_order.line_items = new_line_items
          new_order.update_totals
          new_order.persist_totals if new_order.id
        end

      end
    end
  end
end
