require 'rubygems'
require 'simple-rss'
require 'open-uri'

class Feed < ActiveRecord::Base
  belongs_to :site
  has_many :actions

  def parse    
    feed.items.each do |item|
      action = actions.find_or_create_by_url(item.link)
      action.update_from_feed_item(item)
      action.save!
    end
  end

  def feed
    @rss ||= SimpleRSS.parse(open(url))
  end

  class << self
    def parse_all
      find(:all).each { |feed| puts "Parsing #{feed.name}"; feed.parse }
    end
  end
end
