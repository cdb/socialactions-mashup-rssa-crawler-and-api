class Search < ActiveRecord::BaseWithoutTable
  column :keywords, :string
  column :action_type, :string
  column :created, :integer
  attr_accessor :sites
  
  validates_inclusion_of :created, :in => %w{ 30 14 7 2 1 }

  def build_conditions
    reset_conditions
    add_keywords
    add_action_type
    add_sites
    add_created
    conditions.join(' AND ')
  end
  
  def sites
    @sites ||= []
  end

  def has_site?(site)
    sites.include?(site.id.to_s)
  end

  def reset_conditions
    @conditions = []
  end

  def conditions
    @conditions ||= []
  end

  def add_keywords
    unless keywords.nil? or keywords.empty?
      keyword_conditions = []
      keywords.split(' ').each do |keyword|
        keyword_conditions << sanitize(["description LIKE ?", "%#{keyword}%"]) # TODO add url, title
      end
      conditions << "(" + keyword_conditions.join(' OR ') + ")"
    end
  end
  
  def add_action_type
    unless action_type.nil? or action_type == 'all'
      # conditions << "action_type = '#{action_type}'"
    end
  end
  
  def add_sites
    unless sites.nil? or sites.empty?
      conditions << sanitize(["site_id IN (?)", sites])
    end
  end
  
  def add_created
    unless created.nil?
      conditions << sanitize(["actions.created_at > ?", created.days.ago])
    end
  end
  
  def sanitize(arg)
    ActiveRecord::Base.send(:sanitize_sql, arg)
  end
end
