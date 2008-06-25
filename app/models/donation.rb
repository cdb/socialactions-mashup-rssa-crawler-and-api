class Donation < ActiveRecord::Base
  belongs_to :action
  has_one :donor
  has_one :credit_card
  
  validates_presence_of     :amount
  validates_numericality_of :amount
  
end
