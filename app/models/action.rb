class Action < ActiveRecord::Base
  belongs_to :feed
  delegate :site, :to => :feed
  
  acts_as_taggable
  acts_as_mappable
  
  def update_from_feed_item(item)
    self.title = item.title
    self.url = item.link
    self.description = item.description
    self.created_at = item.pubDate if item.pubDate
    puts "pubDate is #{item.pubDate} created_at is #{self.created_at}"
    figure_out_address_from(item)
  end
  
  def description=(new_description)
    write_attribute(:description, fix_quoted_html(new_description))
    look_for_tags
  end

protected
  def fix_quoted_html(text)
    text.gsub(/\&lt;/, '<').gsub(/\&gt;/, '>')
  end
  
  def look_for_tags
    if feed.tag_finder
      match = description.match(feed.tag_finder.to_s)
      self.tag_list = match[1] if match and match[1]
      puts "Found Tags: #{self.tag_list}"
    end
  end

  def figure_out_address_from(item)
    if item.geo_lat and item.geo_long
      self.latitude = item.geo_lat
      self.longitude = item.geo_long
    end
  end
end
