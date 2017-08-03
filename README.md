Spree Repeat Order
================


This gem adds a "Repeat Order" button to the My Account page on the Spree store shopfront. This way, a user can quickly add all items from a past order to his shopping cart.

The gem adds the following functionality:

- "Repeat Order" button on "My Account" page
- Replaces current shopping cart with repeated order line items

All the operation is done with one single save call, so it will be transactional. In case the order can't be saved for some reason, no line items will be added to the database.


Installation
------------

Add spree_repeat_order to your Gemfile:

	ruby gem 'spree_repeat_order'

Bundle your dependencies and run the installation generator:

	shell
	bundle
	bundle exec rails g spree_repeat_order:install

Testing
-------

Be sure to bundle your dependencies and then create a dummy test app for the specs to run against.

	shell
	bundle
	bundle exec rake test_app
	bundle exec rspec spec


Copyright (c) 2013 Francisco Trindade, released under the New BSD License
