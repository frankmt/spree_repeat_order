require 'spec_helper'

describe Spree::RepeatedOrdersController do

  let(:user) { mock_model(Spree::User, :last_incomplete_spree_order => nil, :has_spree_role? => true, :spree_api_key => 'fake').as_null_object }

  describe "create" do

    let(:line_item_1){ FactoryGirl.create(:line_item) }
    let(:line_item_2){ FactoryGirl.create(:line_item) }
    let(:past_order){ FactoryGirl.create(:order, line_items: [line_item_1, line_item_2]) }
    let(:unavailable_product){ FactoryGirl.create(:product, available_on: nil)}

    let(:new_order){ FactoryGirl.create(:order) }
    let(:line_item_clone_1){ FactoryGirl.create(:line_item) }
    let(:line_item_clone_2){ FactoryGirl.create(:line_item) }

    before :each do
      Spree::Order.stub(:find_by).and_return(past_order)
      controller.stub(:current_order).and_return(new_order)
      controller.stub :spree_current_user => user
      controller.stub :check_authorization
    end

    it 'should create new order with same line items' do
      controller.should_receive(:current_order).at_least(:once).and_return(new_order)
      line_item_1.should_receive(:dup).and_return(line_item_clone_1)
      line_item_2.should_receive(:dup).and_return(line_item_clone_2)

      spree_post :create, number: "ABC1"
      expect(new_order.line_items.count).to eq(2)
      response.should be_redirect
    end

    it 'should skip items that dont exist or are not available' do
      Spree::Order.should_receive(:find_by).with(number: 'ABC1').and_return(past_order)
      Spree::Order.stub(:new).and_return(new_order)

      line_item_1.should_receive(:product).at_least(:once).and_return nil
      line_item_2.should_receive(:product).at_least(:once).and_return unavailable_product

      spree_post :create, number: "ABC1"
      expect(new_order.line_items.count).to eq(0)
    end

    it 'should show success flash message' do
      spree_post :create, number: "ABC1"
      flash[:success].should =~ /added your past order items to the cart/
    end

    it 'should show failure flash message if save fails' do
      new_order.should_receive(:save).and_return(false)
      spree_post :create, number: "ABC1"
      flash[:error].should =~ /could not add your past items to the cart/
    end

  end

  describe "integration" do

    before :each do
      controller.stub :spree_current_user => user
      controller.stub :check_authorization
    end

    it 'should create new order with same line items' do
      past_order = FactoryGirl.create(:order)
      line_item = FactoryGirl.create(:line_item, order: past_order)

      spree_post :create, number: past_order.number

      last_order = Spree::Order.last
      last_order.line_items.count.should == 1
    end

  end

end
