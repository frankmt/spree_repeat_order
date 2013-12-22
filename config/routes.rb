Spree::Core::Engine.routes.append do

  post '/orders/:id/repeated_order' => 'repeated_orders#create'

end
