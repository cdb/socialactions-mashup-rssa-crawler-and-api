require File.dirname(__FILE__) + '/../spec_helper'

describe Donor do
  before(:each) do
    @donor = Donor.new
  end

  it "should be valid" do
    @donor.should be_valid
  end
end
