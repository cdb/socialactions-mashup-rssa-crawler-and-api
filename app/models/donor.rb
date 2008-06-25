class Donor < ActiveRecord::Base
  
  belongs_to :donation
  
  validates_presence_of :ip_address
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :email
  validates_presence_of :address1
  validates_presence_of :city
  validates_presence_of :state
  validates_presence_of :zip
  validates_presence_of :phone
  
  attr_accessor :phone_1, :phone_2, :phone_3
  
end
