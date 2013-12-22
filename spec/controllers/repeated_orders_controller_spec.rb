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
      Spree::Order.stub(:find).and_return(past_order)
    end

    it 'should create new order with same line items' do
      controller.should_receive(:current_order).and_return(new_order)
      line_item_1.should_receive(:dup).and_return(line_item_clone_1)
      line_item_2.should_receive(:dup).and_return(line_item_clone_2)

      new_order.should_receive(:line_items=).with([line_item_clone_1, line_item_clone_2])
      new_order.should_receive(:save).and_return(true)

      spree_post :create, id: "ABC1"
      response.status.should == 201
    end



  end

end
