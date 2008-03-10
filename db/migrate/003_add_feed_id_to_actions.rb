class AddFeedIdToActions < ActiveRecord::Migration
  def self.up
    add_column :actions, :feed_id, :integer
  end

  def self.down
    remove_column :actions, :feed_id
  end
end
