module Spree
  class RepeatedOrdersController < Spree::StoreController

    def create
      render json: {}, status: 201
    end

  end
end
