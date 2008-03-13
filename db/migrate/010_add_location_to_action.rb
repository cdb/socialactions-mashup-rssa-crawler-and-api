class AddLocationToAction < ActiveRecord::Migration
  def self.up
    add_column :actions, :location, :string
  end

  def self.down
    remove_column :actions, :location
  end
end
