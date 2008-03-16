
require 'active_record/fixtures'  
class AddActionTypeToFeed < ActiveRecord::Migration
  def self.up
    add_column :feeds, :action_type, :string
    Fixtures.create_fixtures('spec/fixtures', 'feeds')  
  end

  def self.down
    remove_column :feeds, :action_type
  end
end
