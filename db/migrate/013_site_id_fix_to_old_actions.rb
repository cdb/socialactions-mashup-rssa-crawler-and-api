class SiteIdFixToOldActions < ActiveRecord::Migration
  def self.up
    # Need to fix the ones that end up with a blank site because they've already been crawled and lost in the RSS
    Action.find(:all, :conditions => 'site_id IS NULL').each do |action|
      action.save!
    end
  end

  def self.down
  end
end
