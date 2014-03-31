require 'spec_helper'

describe Spree::Admin::RepeatedOrdersController do

  let(:user) { mock_model Spree::User, :last_incomplete_spree_order => nil, :has_spree_role? => true, :spree_api_key => 'fake' }
  let(:order_user) { mock_model(Spree::User, :last_incomplete_spree_order => nil, :has_spree_role? => true, :spree_api_key => 'fake').as_null_object }

  let(:unavailable_product){ FactoryGirl.build(:product, available_on: nil)}

  let(:ship_address){ FactoryGirl.build(:address) }
  let(:bill_address){ FactoryGirl.build(:address) }
  let(:line_item_1){ FactoryGirl.build(:line_item) }
  let(:line_item_2){ FactoryGirl.build(:line_item) }
  let(:past_order){ FactoryGirl.build(:order, {
    line_items: [line_item_1, line_item_2],
    ship_address: ship_address,
    bill_address: bill_address,
    completed_at: Date.yesterday,
    number: 'ABC1',
    user: order_user
  }) }

  let(:new_order){ double(Spree::Order).as_null_object }
  let(:new_bill_address){ Spree::Address.new }
  let(:new_ship_address){ Spree::Address.new }
  let(:line_item_clone_1){ Spree::LineItem.new }
  let(:line_item_clone_2){ Spree::LineItem.new }

  before :each do
    controller.stub :spree_current_user => user
    controller.stub :check_authorization
  end

  describe 'create' do

    before :each do
      Spree::Order.stub(:find_by).and_return(past_order)
      line_item_clone_1.stub(:reload_price)
      line_item_clone_2.stub(:reload_price)
    end

    it 'should create new order with old order items' do
      Spree::Order.should_receive(:find_by).with(number: 'ABC1').and_return(past_order)
      Spree::Order.stub(:new).and_return(new_order)

      line_item_1.should_receive(:dup).and_return(line_item_clone_1)
      line_item_2.should_receive(:dup).and_return(line_item_clone_2)

      new_order.should_receive(:line_items=).with([line_item_clone_1, line_item_clone_2])
      new_order.should_receive(:save).and_return(true)

      spree_post :create, number: "ABC1"
      response.should be_redirect
    end

    it 'should skip validation and force number generation' do
      Spree::Order.should_receive(:find_by).with(number: 'ABC1').and_return(past_order)
      Spree::Order.stub(:new).and_return(new_order)

      new_order.should_receive(:generate_order_number).and_return(true)
      new_order.should_receive(:save).with(validate: false).and_return(true)

      spree_post :create, number: "ABC1"
      response.should be_redirect
    end

    it 'should skip items that dont exist or are not available' do
      Spree::Order.should_receive(:find_by).with(number: 'ABC1').and_return(past_order)
      Spree::Order.stub(:new).and_return(new_order)

      line_item_1.should_receive(:product).at_least(:once).and_return nil
      line_item_2.should_receive(:product).at_least(:once).and_return unavailable_product

      line_item_1.should_not_receive(:dup)
      line_item_2.should_not_receive(:dup)

      new_order.should_receive(:line_items=).with([])
      new_order.should_receive(:save).and_return(true)

      spree_post :create, number: "ABC1"

    end

    it 'should create order with old customer details' do
      Spree::Order.stub(:new).and_return(new_order)

      ship_address.should_receive(:dup).and_return(new_ship_address)
      bill_address.should_receive(:dup).and_return(new_bill_address)

      new_order.should_receive(:user=).with(order_user)
      new_order.should_receive(:ship_address=).with(new_ship_address)
      new_order.should_receive(:bill_address=).with(new_bill_address)

      spree_post :create, number: "ABC1"
    end

    it 'should fail if original order is not complete' do
      past_order.stub(:completed_at).and_return nil

      spree_post :create, number: "ABC1"
      response.should redirect_to('/admin/orders/ABC1/edit')
    end

    describe 'merging with current order' do

      before :each do
        @new_order = Spree::Order.new
        @new_order.stub(:merge!)
        Spree::Order.stub(:new).and_return(@new_order)
      end

      it 'should merge last incomplete order with new order' do
        incomplete_order = double(Spree::Order)
        order_user.stub(:last_incomplete_spree_order).and_return(incomplete_order)
        @new_order.should_receive(:merge!).with(incomplete_order, order_user)
         
        spree_post :create, number: "ABC1"
      end

      it 'should not merge if user doesnt have a last incomplete order' do
        order_user.stub(:last_incomplete_spree_order).and_return(nil)
        @new_order.should_not_receive(:merge!)
         
        spree_post :create, number: "ABC1"
      end


    end

  end

  describe 'integration' do

    before :each do
      controller.stub :spree_current_user => user
      controller.stub :check_authorization
    end

    it 'should create new order with same line items' do
      user = FactoryGirl.create(:user)
      ship_address = FactoryGirl.create(:address)
      bill_address = FactoryGirl.create(:address)
      past_order = FactoryGirl.create(:completed_order_with_totals, ship_address: ship_address, bill_address: bill_address)

      spree_post :create, number: past_order.number
      response.should redirect_to('/admin/orders')

      last_order = Spree::Order.last
      last_order.line_items.count.should == past_order.line_items.count
      last_order.state.should == 'cart'
      last_order.ship_address.firstname = past_order.ship_address.firstname
      last_order.bill_address.firstname = past_order.bill_address.firstname
    end

  end



end
