class CreateActions < ActiveRecord::Migration
  def self.up
    create_table :actions do |t|
      t.text :description
      t.string :url
      t.text :title

      t.timestamps
    end
  end

  def self.down
    drop_table :actions
  end
end
