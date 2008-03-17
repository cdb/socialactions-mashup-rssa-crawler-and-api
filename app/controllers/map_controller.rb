class MapController < ApplicationController

  include ActionView::Helpers::JavaScriptHelper 
  
  def index
    @search = Search.new(params[:search])
    @search.kind = 'map'
    @search.ip_address = request.remote_ip
    @actions = @search.results(params[:page])
    setup_map
    @actions.each do |action|
      # now for the lat and lng of the marker we want to add. 
      marker_lat = action.latitude
      marker_lng = action.longitude
      @gmap.use_marker_code('createWithIconAndHtml', :with_args => [:point, :html, :icon_image])
      
      incident_point = Mappa::GLatLng.new(:lat => marker_lat, :lng => marker_lng)
      
      @gmap.add_marker(:point => incident_point, :create_with => 'createWithIconAndHtml', :html => "'#{escape_javascript(small_map_view_of(action))}'", :icon_image => "'/images/marker.png'")    
    end
  end

protected
  def setup_map
    @gmap = Mappa::GMap.new()
    @gmap.api_key = 'ABQIAAAAkGYfBpkZ5yYF_f9sthqC5BTJQa0g3IQ9GZqIMmInSLzwtGDKaBRu7u3V_uePSTUgmfHvnGnehFX3-A'

    # set the longitude and latitiude of the centre point of our map
    @gmap.lat, @gmap.lng = @search.current_latitude, @search.current_longitude

    # set the zoom level of our map. This number is in the range of 1-18. 1 is lowest zoom and 18 is highest
    # we've picked a nice middling 12.
    @gmap.zoom = 2
    @gmap.add_control(:control => 'small')
    @gmap.add_control(:control => 'type')
    @gmap.add_control(:control => 'overview')  
  end
 
  
  def small_map_view_of(action)
    %{
      <div class="map-action">
        <div class="title">
          <a href="#{action.url}" target="_blank">#{action.title}</a>
        </div>
        <div class="location">
          <b>Location:</b> #{action.location}
        </div>
        <div class="byline">
          <b>Created on:</b> <a href="#{action.site.url}" target="_blank">#{action.site.name}</a>
        </div>
        <div class="created">
          <b>Created at:</b> #{action.created_at.to_s(:default)}
        </div>
      </div>
    }    
  end
end
