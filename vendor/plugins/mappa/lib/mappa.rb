############################################################
#
# Mappa.rb
# 
# (C) 2006-2007 Andy Mendelsohn
# 
# Map making for Rails applications.
# I'm guessing that it can be used outside of the Rails 
# framework, however it's been written -for- rails.
# Presently the only class used for map making is 
# GMap which generates javascript for the Google GMap2 API code
#
############################################################

module Mappa

  #################################################################
  #
  # Mappa::GMap
  # This Class implements the Google Maps GMap2 API
  # Be aware that it requires an API key that's set at initialisation
  # Testing is done locally with a key generated for localhost:3000
  # the key is: 
  # "ABQIAAAArjtwNyA-0TDmcb74hMzhHBTJQa0g3IQ9GZqIMmInSLzwtGDKaBRSDWK-cqMmi3YB5dD-8a6Kwe1Qmg"
  #
  #################################################################
  
  class NonExistantMJSError < StandardError
  
  end
  
  class GMap
    
    attr_accessor :api_key, :include_funcs, :zoom, :lat, :lng, :js_funcs,
    :js_code, :js_code_lookup, :mjs_path, :js_vars, :onload_func, :onload_func_name,
    :marker_code, :marker_code_funcname_lookup, :marker_code_args,
    :name, :width, :height, :draggable, :polylines, :event_listeners,
    :type, :controls, :markers, :center, :zoom, :class, :icons, :debug, :onload,
    :header_scripts, :center_on_bounds

    def initialize(options = {})
      
      @api_key = options[:api_key]
      @name = options[:name] || 'gmap'
      @zoom = options[:zoom]
      @include_funcs = []
      @type = nil
      @onload_func_name = options[:onload_func_name]  || 'init'
      @onload_func = { :head => '', :tail => ''}
      @js_code = {}
      @js_vars = {}
      @js_code_lookup = {}
      @js_funcs = {}
      @mjs_path = options[:mjs_path] || 'public/javascripts/map_js'
      @marker_code = {}
      @marker_code_funcname_lookup = {}
      @marker_code_args = {}
      @event_listeners = []
      @markers = []
      @controls = []
      @polylines = []
      @center_on_bounds = false
      @onload = true
      @header_scripts = []
      read_js_funcs
    end

    # read_js_funcs reads javascript functions from another directory and reads them into
    # the js_funcs hash. These functions can then be used and called without needing to include
    # them in main controller code
    def read_js_funcs  
      Dir["#{@mjs_path}/_*.mjs"].each do | file |
        fname = File.basename(file).sub(/^_(\w+).mjs/, '\1')

        open(file) do | f |
          @js_funcs[fname] = f.readlines
        end   
      end
    end 
    
    def center_on_bounds?
      @center_on_bounds
    end
          
    # builds the javascript functions for output to view 
    def build_js_funcs()

      js_out = ""
      @include_funcs.each do |fname|
        js_out << "// #{fname}\n"
        raise NonExistantMJSError, "_#{fname}.mjs does not exist in #{@mjs_path}." if @js_funcs[fname].nil? 
        js_out << @js_funcs[fname].join()
        js_out << "//\n"
      
      end
      return js_out
    end
    
    
    # include_funcs is an array of functions to be read into the final javascript. 
    def include_funcs(*funcs)
      @include_funcs = funcs
    end
    
    def header_scripts(*scriptnames)
      @header_scripts = scriptnames
    end
    
    # Google map header required for all google maps.
    def header()
      if @api_key
        "<script src=\"http://maps.google.com/maps?file=api&amp;v=2&amp;key=#{@api_key}\" type=\"text/javascript\"></script>"
      else
        "<!-- Google Map Header requires a valid api. Please add the api key to the relevant code calls. -->"
      end
    end
    
    # map_javascript is the primary method for producing the javascript to be embedded within the view
    def map_javascript(options = {})
      if !map_center && !center_on_bounds?
        "<!-- Google Map requires a lat long centering -->"
      elsif !self.name
        "<!-- Google map requires a name -->"
      else
        "<script type=\"text/javascript\">\n//  <![CDATA[" << build_map << " //]]>\n</script>"
      end
    end
    
    # The main map builder (Called from map_javascript)
    # this will, in due time (i.e., when i need to use the facility!), add the ability to select 
    # js_vars by key (which is why we are using hashes for now.)
    def build_map()
      
      return_string = "\n"
      # see if we have any javascript variables to set up

      if @js_vars.length > 0
        return_string << "// js_vars  //\n"
        return_string << @js_vars.values.to_s
      end
      
      # see if we have any functions to include

      if @include_funcs.length > 0
        return_string << build_js_funcs
      end

      # see if we have any createmarker code 
      
      if @marker_code.length > 0
        return_string << @marker_code.values.to_s
      end
  
      # see if we have any embedded javascript code
      
      if @js_code.length > 0
        return_string << @js_code.values.to_s
      end
      
      if @onload == true
        
        return_string << "
        
              function #{onload_func_name}(){
                if (GBrowserIsCompatible()) {" <<  build_load_func << "
                  
                }
                // display a warning if the browser was not compatible
                else {
                  alert(\"Sorry, the Google Maps API is not compatible with this browser\");
                }
              }
              "
      else
        return_string << "
                if (GBrowserIsCompatible()) {
                  function #{onload_func_name}(){
                    " <<  build_load_func << "
                  }
                  #{onload_func_name}();
                }
                // display a warning if the browser was not compatible
                else {
                  alert(\"Sorry, the Google Maps API is not compatible with this browser\");
                }
              "  
      end
      return return_string
    end
    
    # add arbitrary javascript code from within the body of the controller 
    # (as opposed to calling them in from external files via read_js_funcs)
    def add_js(code_string, options = {})
      @js_code[options[:as]] = code_string
    end    

    # similiar to add_js but this is purely to define javascript variables at the top of the javascript 
    # script block for later use
    def add_js_vars(code_string, options = {})
      @js_vars[options[:as]] = code_string
    end
    
    # add_marker_code provides the ability to add javascript code that's to be called on creation of a marker
    # this allows for different marker creation methods within one map.
    
    def add_marker_code(code_string, options = {})
      funcname = options[:as]
      @marker_code[funcname] = code_string
      @marker_code_funcname_lookup[funcname] = code_string.scan(/function\s+(\w+)\s*\(/)[0]
      @marker_code_args[funcname] = options[:with_args]
    end
    
    # use_marker_code provides the ability to use javascript code that's to be called on creation of a marker
    # this allows for different marker creation methods within one map.
    # The difference between use_marker_code and add_marker_code is that use_marker_code reads code from an .mjs file 
    # which is stored in public/javascripts/map_js
    # This avoids having to embed code within your controller 
    
    def use_marker_code(funcname, options = {})
      
      code_string = @js_funcs[funcname].join()
      @marker_code[funcname] = code_string
      @marker_code_funcname_lookup[funcname] = code_string.scan(/function\s+(\w+)\s*\(/)[0]
      @marker_code_args[funcname] = options[:with_args]

    end
    
    # similiar to add_js but this is purely to define javascript variables at the top of the javascript 
    # script block for later use. The difference between use_js_vars and add_js_vars is that use_js_vars can read the 
    # javascript code from an .mjs file that is stored by default in public/javascripts/map_js
    def use_js_vars(varsname, options = {})
      code_string = @js_funcs[varsname].join()
      @js_vars[options[:as]] = code_string
    end
    
    # add an event_listener
    def add_listener(options)
      listener = Event_listener.new(options)
      @event_listeners << listener
    end
    
    # add map controls
    def add_control(options)
      options[:map_name] = self.name
      control = GControl.new(options)
      @controls << control
    end
    
    # This method constructs and returns the function that's called by the body onload call
    # it includes the ability to add js to the head and tail of the function (within the function body definition)
    # as well.
    def build_load_func
        return_string = ""
        return_string << @onload_func[:head]
        return_string << to_javascript
        return_string << map_onload_func_body
        return_string << @onload_func[:tail]
    end
    
 
    # set the centerpoint of your map.
    def set_center(lat,lng)
      @center = GLatLng.new(:lat => lat, :lng => lng)
    end
    
    def map_center
      if @center
        @center.to_javascript
      elsif @lat && @lng
        set_center(@lat,@lng)
        @center.to_javascript
      else
        false
      end
    end
        
    # the size method will be deprecated as I feel that size of the map, which is a div style size, really should be external to the map code    
    def size(width, height)
      self.width = width
      self.height = height
    end
    
    # The core method for a map. Minimum requirements for a map are: div name, long & lat co-ords and a key
    def to_javascript
      return_string = "
                #{self.name} = new  GMap2(document.getElementById('#{self.name}'));
      "
      if !center_on_bounds?
        return_string <<  " #{self.name}.setCenter(#{self.map_center()},#{self.zoom || 5}); "
      end
      return_string
    end
      
    # Add_marker allows the addition of a marker with or without a bespoke createmarker codeblock. See tests
    # the markers are by calls to a create marker (or without), within the body of the init function
    def add_marker(marker)
      
      marker[:create_with] = 'default' if marker[:create_with].nil? 
      
      @markers << marker
            
    end
    
    # this method builds the body of the function, including controls and markers
    def map_onload_func_body
      return_string = ""
      @controls.each do |control|
        return_string << control.to_javascript
      end

      if !@type.nil?
        types = { 1 => 'G_SATELLITE_TYPE', 2 => 'G_MAP_TYPE', 3 => 'G_HYBRID_TYPE'}
        
        return_string << "#{self.name}.setMapType(#{types[type]});"
      end
    
      @markers.each do | marker |
        if marker[:create_with] == 'default'
          return_string << GMarker.new(marker).to_javascript
        else
          function_key = marker[:create_with]
          funcname = self.marker_code_funcname_lookup[function_key]
          
          func_args = self.marker_code_args[function_key]
          function_call_string = "var marker = #{funcname}("
          func_args.each do | arg |
            if marker[arg].class.name  == 'Mappa::GLatLng'
              function_call_string << marker[arg].to_javascript << ','
            else
              function_call_string << marker[arg].to_s << ','
            end
          end
          
          function_call_string[-1] = ");\n"
          return_string << function_call_string
        end
        return_string << "#{self.name}.addOverlay(marker);\n" if !return_string.nil?
        return_string << "bounds.extend(marker);;\n" if center_on_bounds?
      end
      
      @event_listeners.each do | listener |
        return_string << listener.to_javascript
      end

      if center_on_bounds?
        return_string <<  "   #{self.name}.centerAndZoomOnBounds(bounds);       "
      end
      
      return return_string
    end  
        
    def fetch_js_code(name)
        self.js_code[name]
    end
  
  end
  

  class GMarker
    attr_accessor :point, :marker_options
    
    def initialize(options ={})
      @point = options[:point]
      @marker_options = options[:marker_options]  
    end
       
    def to_javascript
      if !self.point
        "<!-- marker requires a point -->"
      else
        substr = ""
        if self.marker_options 
          substr = "," + self.marker_options.name
        end
        "var marker = new GMarker(#{self.point.to_javascript}#{substr});\n" 
      end
    end
    
  end
  
  # GControl class gives us our standard map controls for google maps. self-explantatory code
  class GControl
  
    attr_accessor :control_anchor, :control_offset, :control, :map_name
    
    @@controls = { :large => 'GLargeMapControl', :small  => 'GSmallMapControl', 
                 :zoom => 'GSmallZoomControl', :type => 'GMapTypeControl',
                 :scale => 'GScaleControl', :overview => 'GOverviewMapControl' }
    
    @@anchors = { :top_right => 'G_ANCHOR_TOP_RIGHT', 
                :top_left => 'G_ANCHOR_TOP_LEFT', 
                :bottom_right => 'G_ANCHOR_BOTTOM_RIGHT', 
                :bottom_left => 'G_ANCHOR_BOTTOM_LEFT' }
    
    def initialize(options ={})
      
      anchor = options[:control_anchor]
      @control_anchor = @@anchors[anchor.to_sym] || nil if !anchor.nil?
      @control_offset = GSize.new(options[:control_offset]) if options[:control_offset]
      control = options[:control]
      
      @control = @@controls[control.to_sym]
      @map_name = options[:map_name]  

    end
    
    def to_javascript
      return_string = ''
      if !@control_anchor.nil?
        if @control_offset 
          return_string << "var gpos = new GControlPosition(#{@control_anchor}, #{@control_offset});\n"
        else
          return_string << "var gpos = new GControlPosition(#{@control_anchor});\n"
        end
          return_string << "#{@map_name}.addControl(new #{@control}(),gpos);\n"
      else
        return_string << "#{@map_name}.addControl(new #{@control}());\n"
      end
      return return_string
    end
  
  end
  
  class GSize
  
    attr_accessor :height, :width
    
    def initialize(options = {})
      @height = options[:height]
      @width = options[:width]
    end
  
    def to_javascript
      return "new GSize(#{@height},#{@width})"
    end
        
  end
  
  # GMarkerOptions are objects that provide options for markers (obvious eh? ;-) ) 
  # given a gmakeroptions object of: 'gmarkeropts', you should be able to do the following:
  # marker = new GMarker(latlng, gmarkeropts);
  class GMarkerOptions
    
    # we assume that if this is a prototype = true, then it's going to have a unique name, 
    # otherwise we generate it based upon the number of objects we've created
    attr_accessor :name, :icon, :drag_cross_move, :title, :clickable, :draggable, :bouncy, :bounce_gravity, :prototype
    @@count = 0
    
    
    def initialize(options ={})      
      
      raise "name cannot end in an underscore followed by a number" if options[:prototype] && options[:name] =~ /_\d+/
      
      @@count = @@count + 1

      @name = options[:name]
      @icon = options[:icon]
      @drag_cross_move = options[:drag_cross_move]
      @title = options[:title]
      @clickable = options[:clickable]
      @draggable =  options[:draggable]
      @bouncy = options[:bouncy]
      @bounce_gravity = options[:bounce_gravity]
      @prototype = options[:prototype]
      if @prototype.nil?
        @name = gen_name
      end
    end
    
    def to_javascript
      "var #{@name} = new GMarkerOptions\n#{@name}.setIcon = #{@icon}"
    end
  
  # Generate a unique name based on the number of new markeroptions objects we've created.  
    def gen_name
      
      "markerOption_#{@@count}"
    end
  end

  # the Point class is the class that is used to create points of the GLatLng class. 
  # this always outputs a javascript variable, which is where the primary difference is between point and GLatLng 
  # in fact, Some might say "that's the point of it!"
  # There is no actual GMap2 class equivalent
  # We generate a unique var name if the unique option is set to 1
  #
  class Point 
    
    attr_accessor :lat, :lng
    @@count = 0
    
    def initialize(options = {})
      if options[:unique] == 1
        @@count +=1
        @unique_counter = @@count
      else
        @unique_counter = nil
      end
      @lat = options[:lat]
      @lng = options[:lng]
    end
    
    def to_javascript
      if !@unique_counter.nil?
        "var point_#{@unique_counter} = " << Mappa::GLatLng.new(:lat => @lat, :lng => @lng).to_javascript << ";"
      else
        "var point = "<< Mappa::GLatLng.new(:lat => @lat, :lng => @lng).to_javascript << ";"
      end
    end
    
  end
  
  # Event_listener is used to give us our gmap event handlers, onclicks, etc.
  
  class Event_listener
    attr_accessor :action, :method, :element
  # Creator and accessor for the GMap2 GLatLng equivalent.
  # 
    def initialize(options = {:action => nil, :method => nil, :element => nil})
      raise ArgumentError.new("events must have an action") if options[:action].nil?
      raise ArgumentError.new("events must have a method") if options[:method].nil?
      raise ArgumentError.new("events must have an elelemt") if options[:element].nil?
    
    
     @action = options[:action]
     @method = options[:method]
     @element = options[:element]
    end


    def to_javascript
        "
        GEvent.addListener(#{@element}, '#{@action}', #{@method});"
    end
    
  end
  
  # GLatLng method is merely responsible for sending back the javascript for a new GLatLng object that's then fed to any number of other 
  #objects. It's used to center maps as well as for providing the co-ords to a GMarker object
  
  class GLatLng
  
    attr_accessor :lat, :lng
    
    def initialize(options = {})
      @lat = options[:lat]
      @lng = options[:lng]
    end
    
    def to_javascript
      "new GLatLng(#{@lat},#{@lng})"
    end
  
  end
  
  # GIcon creates all that's necessary for the production of unique icon code. the variable name is then used in conjunction with a gmarker to 
  # generate a new marker with a specific icon. 
  
  class GIcon
    
    attr_accessor :name, :image, :from, :shadow, :icon_size, :shadow_size, :icon_anchor, :info_window_anchor, :info_shadow_anchor
    @@count = 0
  # todo: must test for must-have name and image
  
    def initialize(options = {})
      raise "name cannot end in an underscore followed by a number" if @prototype && @name =~ /_\d+/      
      @@count +=1
      @name = options[:name]
      @image = options[:image]
      @from = options[:from] || ""
      @shadow = options[:shadow] || "http://www.google.com/mapfiles/shadow50.png"
      if options[:icon_size]
        icon_size = options[:icon_size]
        width = icon_size[:width]
        height = icon_size[:height]
        @icon_size = GSize.new(:height => height, :width => width)
      else
        @icon_size = GSize.new(:height => 20, :width => 34)
      end
      if options[:shadow_size]
        shadow_size = options[:shadow_size]
        width = shadow_size[:width]
        height = shadow_size[:height]
        @shadow_size = GSize.new(:height => height, :width => width)
      else
        @shadow_size = GSize.new(:height => 37, :width => 34)
      end
      if options[:icon_anchor]
        icon_anchor = options[:icon_anchor]
        @icon_ancher = GPoint.new(:x => icon_anchor[:x], :y => icon_anchor[:y])
      else
        @icon_anchor = GPoint.new(:x => 9, :y => 34)
      end
      if options[:info_window_anchor]
        info_window_anchor = options[:info_window_anchor]
        @info_window_ancher = GPoint.new(:x => info_window_anchor[:x], :y => info_window_anchor[:y])
      else
        @info_window_anchor = GPoint.new(:x => 9, :y => 2)
      end
      if options[:info_shadow_anchor]
        info_shadow_anchor = options[:info_shadow_anchor]
        @info_shadow_ancher = GPoint.new(:x => info_shadow_anchor[:x], :y => info_shadow_anchor[:y])
      else
        @info_shadow_anchor = GPoint.new(:x => 9, :y => 2)
      end
      if @name.nil?
          @name = gen_name
      end
    end
    
    def to_javascript
      return_string = ""
      if !@from.nil?
        return_string << "var #{gen_name()} = new GIcon(#{@from});\n" 
      else
        return_string << "var #{gen_name()} = new GIcon();\n"
      end
      return_string << "#{@name}.image = '#{@image}';\n" if !@image.nil?
      return_string << "#{@name}.shadow = '#{@shadow}';\n" if !@shadow.nil?
      return_string << "#{@name}.iconSize = #{@icon_size.to_javascript};\n" if !@icon_size.nil?
      return_string << "#{@name}.shadowSize = #{@shadow_size.to_javascript};\n" if !@shadow_size.nil?
      return_string << "#{@name}.iconAnchor = #{@icon_anchor.to_javascript};\n" if !@icon_anchor.nil?
      return_string << "#{@name}.infoWindowAnchor = #{@info_window_anchor.to_javascript};\n" if !@info_window_anchor.nil?
      return_string << "#{@name}.infoShadowAnchor = #{@info_shadow_anchor.to_javascript};\n" if !@info_shadow_anchor.nil?
    end
    # Generate a unique name based on the number of icons we've set up
    def gen_name
      "gicon_#{@@count}"
    end
    
    def return_icon
      @name
    end
  end

# GPoints are used in lots of places. basically they are x/y co-ordinated points, as opposed to long and lat points.
    
  class GPoint
    
    def initialize(options = {})
        @x = options[:x]
        @y = options[:y]
    end

    def to_javascript
      "new GPoint(#{@x},#{@y})"
    end
  end

# TODO (soon!): polyines and polygons are pretty straightforward. Simple methods need to be fleshed out. At present they are easily created in
# external javascript embedded within code read in (which is how i'm dealing with it right now). Using external, non-autogenerated code, is probably
# the most flexible way of doing it right now.

  class GPolyline
    
    attr_accessor :points, :color, :weight, :opacity
    
    def initialize(options = {})
      
    end
    
  end
  
  class GPolygon
    
    attr_accessor :points, :fill, :color, :opacity, :outline
    
    def initialize(options = {})
      
    end
    
  end
     
end