class ChangeActionPrecision < ActiveRecord::Migration
  def self.up
    change_column :actions, :latitude, :decimal, :precision => 15, :scale => 10
    change_column :actions, :longitude, :decimal, :precision => 15, :scale => 10
  end

  def self.down
  end
end
