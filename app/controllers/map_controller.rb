class MapController < ApplicationController

  before_filter :setup_map
  
  include ActionView::Helpers::JavaScriptHelper 
  
  def index
    actions = Action.find(:all, :origin => [current_latitude, current_longitude], :conditions => 'latitude IS NOT NULL and longitude IS NOT NULL')
    actions.each do |action|
      # now for the lat and lng of the marker we want to add. 
      marker_lat = action.latitude
      marker_lng = action.longitude
      @gmap.use_marker_code('createWithIconAndHtml', :with_args => [:point, :html, :icon_image])
      
      incident_point = Mappa::GLatLng.new(:lat => marker_lat, :lng => marker_lng)
      
      @gmap.add_marker(:point => incident_point, :create_with => 'createWithIconAndHtml', :html => "'#{escape_javascript(small_map_view_of(action))}'", :icon_image => "'/images/marker.png'")    
    end
    # render :template => "map/index"


  end

protected
  def setup_map
    @gmap = Mappa::GMap.new()
    @gmap.api_key = 'ABQIAAAAkGYfBpkZ5yYF_f9sthqC5BTJQa0g3IQ9GZqIMmInSLzwtGDKaBRu7u3V_uePSTUgmfHvnGnehFX3-A'

    # set the longitude and latitiude of the centre point of our map
    @gmap.lat, @gmap.lng = current_latitude, current_longitude

    # set the zoom level of our map. This number is in the range of 1-18. 1 is lowest zoom and 18 is highest
    # we've picked a nice middling 12.
    @gmap.zoom = 4
    @gmap.add_control(:control => 'small')
    @gmap.add_control(:control => 'type')
    @gmap.add_control(:control => 'overview')  
  end
  
  def current_latitude
    current_location.lat || 41.98
  end
  
  def current_longitude
    current_location.lng || -87.90
  end
  
  def current_location
    # debugger
    @current_location ||= GeoKit::Geocoders::IpGeocoder.geocode(current_ip)
  end
  
  def current_ip
    request.remote_ip == '127.0.0.1' ? '67.162.124.13' : request.remote_ip
  end
  
  # def get_current_location
  #   location = GeoKit::Geocoders::IpGeocoder.geocode(request.remote_ip)
  #   unless location.lat.nil? and location.lng.nil?
  #     return location.lat, location.lng
  #   else
  #     return 41.98, -87.90 # Chicago, an estimate
  #   end
  # end
  
  def small_map_view_of(action)
    %{
      <div class="map-action">
        <div class="title">
          <a href="/actions/#{action.id}">#{action.title}</a>
        </div>
        <div class="location">
          <b>Location:</b> #{action.location}
        </div>
        <div class="byline">
          <b>Created on:</b> <a href="#{action.site.url}">#{action.site.name}</a>
        </div>
        <div class="created">
          <b>Created at:</b> #{action.created_at.to_s(:default)}
        </div>
      </div>
    }    
  end
end
