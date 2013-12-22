require 'spec_helper'

describe Spree::RepeatedOrdersController do

  describe "create" do

    let(:line_item_1){ FactoryGirl.build(:line_item) }
    let(:line_item_2){ FactoryGirl.build(:line_item) }
    let(:past_order){ FactoryGirl.build(:order, line_items: [line_item_1, line_item_2]) }

    let(:new_order){ FactoryGirl.build(:order) }
    let(:line_item_clone_1){ FactoryGirl.build(:line_item) }
    let(:line_item_clone_2){ FactoryGirl.build(:line_item) }

    before :each do
      Spree::Order.stub(:find_by).and_return(past_order)
      controller.stub(:current_order).and_return(new_order)
    end

    it 'should create new order with same line items' do
      controller.should_receive(:current_order).and_return(new_order)
      line_item_1.should_receive(:dup).and_return(line_item_clone_1)
      line_item_2.should_receive(:dup).and_return(line_item_clone_2)

      new_order.should_receive(:line_items=).with([line_item_clone_1, line_item_clone_2])
      new_order.should_receive(:save).and_return(true)

      spree_post :create, number: "ABC1"
      response.should be_redirect
    end

  end

  describe "integration" do

    it 'should create new order with same line items' do
      past_order = FactoryGirl.create(:order)
      line_item = FactoryGirl.create(:line_item, order: past_order)

      spree_post :create, number: past_order.number

      last_order = Spree::Order.last
      last_order.line_items.count.should == 1
    end

  end

end
