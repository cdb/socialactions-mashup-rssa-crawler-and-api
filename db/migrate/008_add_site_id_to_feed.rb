class AddSiteIdToFeed < ActiveRecord::Migration
  def self.up
    add_column :feeds, :site_id, :integer
  end

  def self.down
    remove_column :feeds, :site_id
  end
end
