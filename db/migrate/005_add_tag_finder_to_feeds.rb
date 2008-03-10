class AddTagFinderToFeeds < ActiveRecord::Migration
  def self.up
    add_column :feeds, :tag_finder, :string
  end

  def self.down
    remove_column :feeds, :tag_finder
  end
end
