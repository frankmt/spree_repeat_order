  Deface::Override.new(:virtual_path => "spree/users/show",
                       :name => "my_account_table",
                       :replace => "[data-hook='account_my_orders'] table",
                       :partial => "spree/users/my_account_table",
                       :disabled => false)
