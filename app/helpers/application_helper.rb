# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def map_loader
    if !@gmap.nil? && @gmap.onload
      {:onload => @gmap.onload_func_name + '()', :onunload => 'GUnload'}
    else
      {}
    end
  end
end
