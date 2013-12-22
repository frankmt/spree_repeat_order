require 'spec_helper'

describe Spree::RepeatedOrdersController do

  describe "create" do

    it 'should return 201' do
      spree_post :create
      response.status.should == 201
    end

  end

end
