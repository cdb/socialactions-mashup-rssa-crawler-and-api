require File.dirname(__FILE__) + '/../spec_helper'

describe Donation do
  before(:each) do
    @donation = Donation.new
  end

  it "should be valid" do
    @donation.should be_valid
  end
end
