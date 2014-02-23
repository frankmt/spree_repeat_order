module Spree
  class RepeatedOrdersController < Spree::StoreController

    include Spree::SpreeRepeatedOrder::ControllerHelpers::RepeatedOrder

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

    def check_authorization
      session[:access_token] ||= params[:token]

      order = Spree::Order.find_by_number(params[:number])
      authorize! :edit, order, session[:access_token]
    end

  end
end
