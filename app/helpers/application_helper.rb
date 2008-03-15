# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def map_loader
    if !@gmap.nil? && @gmap.onload
      {:onload => @gmap.onload_func_name + '()', :onunload => 'GUnload'}
    else
      {}
    end
  end
  
  def options_for_action_type_select
    options_for_select([
    	['All actions', "all"],
      ['Group fundraising', "fundraiser"],
      ['Grassroots petition', "petitions"],
      ['Volunteer opportunity', "volunteer"],
      ['Collective action', "pledge"],
      ['Affinity group', "affinitygroup"]
    ])
  end
  
  def options_for_created_select
    options_for_select([
      ['Last 30 days', "last30days"],
    	['Last 14 days',"last14days"],
    	['Last week', "lastweek"],
    	['Yesterday', "yesterday"],
    	['Today', "today"]
    ])
  end
  
  def tag_list_for(action)
    action.tags.collect do |tag|
      link_to tag.name, tag_path(tag)
    end.join(', ')
  end
  
end
