class AddLocationFinderToFeed < ActiveRecord::Migration
  def self.up
    add_column :feeds, :location_finder, :string
  end

  def self.down
    remove_column :feeds, :location_finder
  end
end
