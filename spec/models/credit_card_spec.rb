require File.dirname(__FILE__) + '/../spec_helper'

describe CreditCard do
  before(:each) do
    @credit_card = CreditCard.new
  end

  it "should be valid" do
    @credit_card.should be_valid
  end
end
