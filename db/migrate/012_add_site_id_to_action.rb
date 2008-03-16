class AddSiteIdToAction < ActiveRecord::Migration
  def self.up
    add_column :actions, :site_id, :integer
  end

  def self.down
    remove_column :actions, :site_id
  end
end
