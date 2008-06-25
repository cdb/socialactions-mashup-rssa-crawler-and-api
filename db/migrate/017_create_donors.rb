class CreateDonors < ActiveRecord::Migration
  def self.up
    create_table :donors do |t|
      t.integer :donation_id
      t.string :ip_address
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :cc_email
      t.string :address1
      t.string :address2
      t.string :city
      t.string :state
      t.string :zip
      t.string :phone
      t.timestamps
    end
  end

  def self.down
    drop_table :donors
  end
end
