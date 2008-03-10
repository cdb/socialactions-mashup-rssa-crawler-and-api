require File.dirname(__FILE__) + '/../spec_helper'

describe Action do
  before(:each) do
    @action = Action.new
  end

  it "should be valid" do
    @action.should be_valid
  end
end

describe "An Action" do
  before(:each) do
    @action = Action.new(:feed => feeds(:global_giving))
  end
  
  it "should convert &gt; and &lt; into < and > in the description" do
    @action.description = 'This is &lt;b&gt;bold&lt;/b&gt;'
    @action.description.should eql('This is <b>bold</b>')
  end
  
  it "should allow itself to be tagged" do
    @action.tags.should eql([])
    @action.tag_list = 'Something, OrOther'
    @action.save!
    @action.tags.size.should equal(2)
  end
  
  it "should find tags in it's description" do
    @action.tags.should eql([])
    @action.feed.tag_finder = '<br />Tags: ([\w\s,]+)<br />'
    @action.description = "Test hello <br />Tags: Something, OrOther<br /> world"
    @action.save!
    @action.tags.size.should equal(2)
  end
end
