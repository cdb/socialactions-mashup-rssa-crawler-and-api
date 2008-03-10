require File.dirname(__FILE__) + '/../spec_helper'

describe Feed do
  before(:each) do
    @feed = Feed.new
  end

  it "should be valid" do
    @feed.should be_valid
  end
end

describe "A feed" do
  before(:each) do
    @feed = feeds(:global_giving)
  end
  
  it "should make an HTTP request to it's URL when parse is called" do
    # URI.stubs!(:open).and_returns(true)
    @feed.parse
  end
end
