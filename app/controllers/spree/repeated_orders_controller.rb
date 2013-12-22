module Spree
  class RepeatedOrdersController < Spree::StoreController

    before_filter :check_authorization

    def create
      past_order = Spree::Order.find_by(number: params[:number])
      new_order = current_order(true)

      duplicate_order(past_order, new_order)

      if new_order.save
        flash[:success] = 'We have added your past order items to the cart. Just proceed to checkout to complete it.'
      else
        flash[:error] = 'We are sorry, but we could not add your past items to the cart.'
      end

      redirect_to(cart_path)
    end

    private

    def duplicate_order(past_order, new_order)
      new_line_items = []
      past_order.line_items.each do |line_item|
        new_line_items << line_item.dup
      end

      new_order.line_items = new_line_items
    end

    def check_authorization
      session[:access_token] ||= params[:token]

      order = Spree::Order.find_by_number(params[:number])
      authorize! :edit, order, session[:access_token]
    end

  end
end
