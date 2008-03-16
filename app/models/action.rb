class Action < ActiveRecord::Base

  include GeoKit::Geocoders

  belongs_to :feed
  belongs_to :site
  
  acts_as_taggable
  acts_as_mappable :lat_column_name => :latitude, :lng_column_name => :longitude
  
  before_save :look_for_tags, :look_for_location, :geocode_lookup, :denormalize
  
  def update_from_feed_item(item)
    puts "  -- Action: #{item.title}"
    self.title = item.title
    self.url = item.link
    self.description = item.description
    self.created_at = item.pubDate if item.pubDate
    figure_out_address_from(item)
  end
  
  def description=(new_description)
    write_attribute(:description, fix_quoted_html(new_description))
  end

  def self.per_page
    10
  end

protected
  def fix_quoted_html(text)
    text.gsub(/\&lt;/, '<').gsub(/\&gt;/, '>')
  end
  
  def look_for_location
    if feed.location_finder and self.description
      match = self.description.match(feed.location_finder.to_s)
      self.location = match[1] if match and match[1]
      puts "     Found Location: #{self.location}"
    end
  end
  
  def look_for_tags
    if feed.tag_finder and description
      match = description.match(feed.tag_finder.to_s)
      self.tag_list = match[1] if match and match[1]
      puts "     Found Tags: #{self.tag_list}"
    end
  end

  def figure_out_address_from(item)
    if item.geo_lat and item.geo_long
      self.latitude = item.geo_lat
      self.longitude = item.geo_long
    end
  end
  
  def geocode_lookup
    unless location.nil? or location.empty?
      result = MultiGeocoder.geocode(location)
      if result.success
        self.latitude = result.lat
        self.longitude = result.lng
        puts "     Geocoding Successful - #{result}" 
      end
    end
  end
  
  
  def denormalize
    self.site_id = self.feed.site_id
    self.action_type = self.feed.action_type
  end
  
end
