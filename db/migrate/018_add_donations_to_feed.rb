class AddDonationsToFeed < ActiveRecord::Migration
  def self.up
    add_column :feeds, :donations, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :feeds, :donations
  end
end
