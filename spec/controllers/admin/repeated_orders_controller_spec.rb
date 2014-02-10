require 'spec_helper'

describe Spree::Admin::RepeatedOrdersController do

  let(:user) { mock_model Spree::User, :last_incomplete_spree_order => nil, :has_spree_role? => true, :spree_api_key => 'fake' }

  let(:ship_address){ FactoryGirl.build(:address) }
  let(:bill_address){ FactoryGirl.build(:address) }
  let(:line_item_1){ FactoryGirl.build(:line_item) }
  let(:line_item_2){ FactoryGirl.build(:line_item) }
  let(:past_order){ FactoryGirl.build(:order, {
    line_items: [line_item_1, line_item_2],
    ship_address: ship_address,
    bill_address: bill_address,
    completed_at: Date.yesterday,
    number: 'ABC1'
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

    it 'should create order with old customer details' do
      Spree::Order.stub(:new).and_return(new_order)

      ship_address.should_receive(:dup).and_return(new_ship_address)
      bill_address.should_receive(:dup).and_return(new_bill_address)

      new_order.should_receive(:ship_address=).with(new_ship_address)
      new_order.should_receive(:bill_address=).with(new_bill_address)

      spree_post :create, number: "ABC1"
    end

    it 'should fail if original order is not complete' do
      past_order.stub(:completed_at).and_return nil

      spree_post :create, number: "ABC1"
      response.should redirect_to('/admin/orders/ABC1')
    end

  end

  describe 'integration' do

    before :each do
      controller.stub :spree_current_user => user
      controller.stub :check_authorization
    end

    it 'should create new order with same line items' do
      ship_address = FactoryGirl.create(:address)
      bill_address = FactoryGirl.create(:address)
      past_order = FactoryGirl.create(:order, ship_address: ship_address, bill_address: bill_address)
      line_item = FactoryGirl.create(:line_item, order: past_order)

      spree_post :create, number: past_order.number

      last_order = Spree::Order.last
      last_order.line_items.count.should == 1
    end

    it 'should save order in delivery state'

  end



end