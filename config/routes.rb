Spree::Core::Engine.routes.draw do

  post '/orders/:number/repeated_order' => 'repeated_orders#create', as: :repeat_order

end
