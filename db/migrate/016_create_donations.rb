class CreateDonations < ActiveRecord::Migration
  def self.up
    create_table :donations do |t|
      t.integer :action_id
      t.string  :ein
      t.string  :designation
      t.string  :dedication
      t.string  :disclosure
      t.string  :amount
      t.string  :identifier
      t.string  :fee_option
      t.timestamps
    end
  end

  def self.down
    drop_table :donations
  end
end
