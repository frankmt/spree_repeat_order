Spree::LineItem.class_eval do

  def reload_price
    if variant
      self.price = variant.price
      self.cost_price = variant.cost_price
      self.currency = variant.currency
    end
  end

end
