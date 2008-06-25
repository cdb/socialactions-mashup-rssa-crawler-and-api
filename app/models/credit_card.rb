class CreditCard < ActiveRecord::Base
  # Stuff to make this a database-less model
  def self.columns() @columns ||= []; end
  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end

  column :donation_id,  :integer
  column :type,         :string
  column :name,         :string
  column :number,       :string
  column :expiry_date, :integer
  column :csc,          :integer
                                       
  validates_presence_of   :type
  validates_presence_of   :name
  validates_presence_of   :number
  validates_presence_of   :expiry_month    
  validates_presence_of   :expiry_year     
  validates_presence_of   :csc

end
