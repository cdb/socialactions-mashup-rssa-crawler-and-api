class AddLatlongToActions < ActiveRecord::Migration
  def self.up
    add_column :actions, :latitude, :decimal, :precision => 10, :scale => 10
    add_column :actions, :longitude, :decimal, :precision => 10, :scale => 10
  end

  def self.down
    remove_column :actions, :latitude
    remove_column :actions, :longitude
  end
end
