Spree::Core::Engine.routes.draw do

  post '/orders/:number/repeated_order' => 'repeated_orders#create', as: :repeat_order
  post '/admin/orders/:number/repeated_order/' => 'admin/repeated_orders#create', as: :admin_repeat_order

end
