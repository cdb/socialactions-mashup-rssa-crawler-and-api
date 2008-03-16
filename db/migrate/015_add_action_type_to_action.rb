class AddActionTypeToAction < ActiveRecord::Migration
  def self.up
    add_column :actions, :action_type, :string
    Feed.find(:all).each do |feed|
      execute("UPDATE actions SET action_type = '#{feed.action_type}' WHERE feed_id = #{feed.id}")
    end
  end

  def self.down
    remove_column :actions, :action_type
  end
end
