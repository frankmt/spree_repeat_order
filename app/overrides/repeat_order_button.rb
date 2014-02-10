Deface::Override.new(:virtual_path => "spree/admin/shared/_content_header",
                     :name => "repeat_order_button",
                     :insert_top => "[data-hook='toolbar']>ul",
                     :partial => "spree/admin/orders/repeat_button",
                     :disabled => false)
