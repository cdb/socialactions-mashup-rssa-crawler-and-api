# require File.dirname(__FILE__) + '/test_helper'
require 'test/unit'
require File.dirname(__FILE__) + '/../lib/Mappa'

class MappaTest < Test::Unit::TestCase

  include Mappa
  
  def setup
    @map = Mappa::GMap.new()    
    @marker =   Mappa::GMarker.new()    
    @map2 = Mappa::GMap.new()
    @map2.lat = 43.907787
    @map2.lng = -79.359741
    @map2.name = "mymap"
    @map3 = Mappa::GMap.new()
    @map3.lat = 43.907787
    @map3.lng = -79.359741
    @map3.name = "mymap"    
  end
  
  def test_should_read_javascript_from_path
    @map.mjs_path = 'test/test_mappa'
    @map.read_js_funcs()
    assert_equal 3, @map.js_funcs.length()
  end

  def test_should_build_javascript_from_hash
    @map.mjs_path = 'test/test_mappa'
    @map.read_js_funcs()
    @map.include_funcs( 'function1','function3','function2')
    assert_equal "// function1
function function1() {
  return 1;
}
//
// function3
function function3() {
  return 3;
}
//
// function2
function function2() {
  return 2;
}
//
", @map.build_js_funcs
  end

  def test_should_not_provide_header_without_api_key
    assert_equal "<!-- Google Map Header requires a valid api. Please add the api key to the relevant code calls. -->", @map.header
  end
  
  def test_should_provide_header_with_api_key
    # @map api_key for localhost 3000
    @map.api_key = "ABQIAAAArjtwNyA-0TDmcb74hMzhHBTJQa0g3IQ9GZqIMmInSLzwtGDKaBRSDWK-cqMmi3YB5dD-8a6Kwe1Qmg"
    
    assert_equal "<script src=\"http://maps.google.com/maps?file=api&amp;v=2&amp;key=ABQIAAAArjtwNyA-0TDmcb74hMzhHBTJQa0g3IQ9GZqIMmInSLzwtGDKaBRSDWK-cqMmi3YB5dD-8a6Kwe1Qmg\" type=\"text/javascript\"></script>", @map.header
  end  
    
  def test_should_not_build_map_without_name
    @map.lat = 43.907787
    @map.lng = -79.359741
    assert_equal "<!-- Google map requires a name -->", @map.map_javascript
  end
  
  def test_should_not_provide_map_without_latlong
    assert_equal "<!-- Google Map requires a lat long centering -->", @map.map_javascript
  end
  
  def test_should_provide_map_with_latlong_and_name
      assert_equal "<script type=\"text/javascript\">
//  <![CDATA[

              function init(){
                if (GBrowserIsCompatible()) {
                mymap = new  GMap2(document.getElementById('mymap'));
                mymap.setCenter(new GLatLng(43.907787,-79.359741),5);

                }
                // display a warning if the browser was not compatible
                else {
                  alert(\"Sorry, the Google Maps API is not compatible with this browser\");
                }
              }
               //]]>
</script>", @map2.map_javascript
    
  end

  def test_should_return_gmarker_error_without_point
    @marker =   Mappa::GMarker.new()
    
    assert_equal "<!-- marker requires a point -->", @marker.to_javascript
  end
  
  def test_should_return_gmarker_with_point
    @marker.point = Mappa::GLatLng.new(:lat => 43.907787, :lng => -79.359741)    
    assert_equal "new GMarker(new GLatLng(43.907787,-79.359741))", @marker.to_javascript      
  end
  
  def test_should_return_icon_constructor
    @marker_icon = Mappa::GIcon.new(:image => 'my.png')
    assert_equal "var #{@marker_icon.gen_name} = new GIcon();
#{@marker_icon.gen_name}.image = 'my.png';
#{@marker_icon.gen_name}.shadow = 'http://www.google.com/mapfiles/shadow50.png';
#{@marker_icon.gen_name}.iconSize = new GSize(20,34);
#{@marker_icon.gen_name}.shadowSize = new GSize(37,34);
#{@marker_icon.gen_name}.iconAnchor = new GPoint(9,34);
#{@marker_icon.gen_name}.infoWindowAnchor = new GPoint(9,2);
#{@marker_icon.gen_name}.infoShadowAnchor = new GPoint(9,2);
", @marker_icon.to_javascript
  end
  
  def test_should_return_gmarker_with_point_and_icon
  
    @marker_options1 = Mappa::GMarkerOptions.new(:icon => 'my.png')
    @marker.marker_options = @marker_options1
    @marker.point = Mappa::GLatLng.new(:lat => 43.907787, :lng => -79.359741)    
    
    assert_equal "var #{@marker_options1.name} = new GMarkerOptions\n#{@marker_options1.name}.setIcon = #{@marker_options1.icon}", @marker_options1.to_javascript
    assert_equal "new GMarker(new GLatLng(43.907787,-79.359741),#{@marker_options1.name})", @marker.to_javascript
    
  end
  
  def test_should_return_point_with_latlng
    
    @point = Mappa::Point.new(:lat => 43.907787, :lng => -79.359741)
    assert_equal "var point = new GLatLng(43.907787,-79.359741);",  @point.to_javascript
  
  end

  def test_should_return_incremented_unique_point_with_latlng
    
    @point = Mappa::Point.new(:unique => 1, :lat => 43.907787, :lng => -79.359741)
    assert_equal "var point_1 = new GLatLng(43.907787,-79.359741);", @point.to_javascript
    
    @point2 = Mappa::Point.new(:unique => 1, :lat => 43.907787, :lng => -79.359741)
    assert_equal  "var point_2 = new GLatLng(43.907787,-79.359741);", @point2.to_javascript
  
    @point = Mappa::Point.new(:unique => 1, :lat => 43.907787, :lng => -79.359741)
    assert_equal "var point_3 = new GLatLng(43.907787,-79.359741);", @point.to_javascript

  end
    
  def test_should_increment_gmarkeroption_generated_name
    @marker_options2 = Mappa::GMarkerOptions.new(:icon => 'your.png')
    assert_equal "markerOption_1", @marker_options2.name
    @marker_options3 = Mappa::GMarkerOptions.new(:icon => 'whose.png')
    assert_equal "markerOption_1", @marker_options2.name
    assert_equal "markerOption_2", @marker_options3.name
  end
  
  def test_marker_options_should_throw_an_exception_if_underscore_followed_by_number_for_proto_names
    begin
      @marker_options2 = Mappa::GMarkerOptions.new(:icon => 'worst.png', :prototype => true, :name =>'worst_1')
    rescue Exception => e
      error_message = e.message
    end
    assert_equal "name cannot end in an underscore followed by a number", error_message
    assert_raise(RuntimeError) { @marker_options2 = Mappa::GMarkerOptions.new(:icon => 'worst.png', :prototype => true, :name =>'worst_1') } 
  end
  
  def test_should_return_correct_js_string_from_GLatLang
    @latlang =  Mappa::GLatLng.new(:lat => 43.907787, :lng => -79.359741)
    assert "new GLatLang(43.907787,-79.359741)", @latlang.to_s
  end

  def test_should_allow_adding_javascript_vars
    jstring_head = "
     var gmap = null; 
     var keycount = 0;
     var pointArray = {};
     var pointlist = [];
     var markers = {};
     var latlngs = {};
     var points = [];
     var editable = true;
     var oldpolyline = null;
     var lastPosition = 0;
     "

     @map3.add_js_vars(jstring_head, :as => 'header_vars')
     assert @map3.js_vars.to_s, "
      var gmap = null; 
      var keycount = 0;
      var pointArray = {};
      var pointlist = [];
      var markers = {};
      var latlngs = {};
      var points = [];
      var editable = true;
      var oldpolyline = null;
      var lastPosition = 0;
      "    
    
    end
    
  def test_should_allow_adding_jscript
    jstring = "
    function createMarker(point,name,html) {
      var marker = new GMarker(point);
      GEvent.addListener(marker, \"click\", function() {
        marker.openInfoWindowHtml(html);
      });
      // save the info we need to use later for the sidebar
      gmarkers[i] = marker;
      htmls[i] = html;
      i++;
      return marker;
    }
    
    "
    
    @map.add_js(jstring, :as => 'create_with_html')
    assert_equal jstring, @map.fetch_js_code('create_with_html')
  end  
  
  def test_should_include_extra_js_with_output
        
    jstring = "
    function createMarker(point,name,html) {
      var marker = new GMarker(point);
      GEvent.addListener(marker, \"click\", function() {
        marker.openInfoWindowHtml(html);
      });
    }
    
    "
    
    @map2.add_js(jstring, :as => 'create_with_html')
    
    assert_equal "<script type=\"text/javascript\">
//  <![CDATA[
    function createMarker(point,name,html) {
      var marker = new GMarker(point);
      GEvent.addListener(marker, \"click\", function() {
        marker.openInfoWindowHtml(html);
      });
    }
    
    

              function init(){
                if (GBrowserIsCompatible()) {
                mymap = new  GMap2(document.getElementById('mymap'));
                mymap.setCenter(new GLatLng(43.907787,-79.359741),5);

                }
                // display a warning if the browser was not compatible
                else {
                  alert(\"Sorry, the Google Maps API is not compatible with this browser\");
                }
              }
               //]]>
</script>", @map2.map_javascript
        # </script>", @map2.map_onload_javascript
  end
  
  def test_that_marker_is_added_with_correct_js_code

    jstring = "
    function createMarker(point,html) {
      var marker = new GMarker(point);
      GEvent.addListener(marker, \"click\", function() {
        marker.openInfoWindowHtml(html);
      });
    }
    
    "
    @map2.add_marker_code(jstring, :as => 'create_with_html', :with_args => [:point, :html])

    @point = Mappa::GLatLng.new(:lat => 10.907787, :lng => 40.359741)
    
    @map2.add_marker(:point => @point, :create_with => 'create_with_html', :html => "'<b>This is some html!</b>'")
        
    assert_equal "<script type=\"text/javascript\">
//  <![CDATA[
    function createMarker(point,html) {
      var marker = new GMarker(point);
      GEvent.addListener(marker, \"click\", function() {
        marker.openInfoWindowHtml(html);
      });
    }
    
    

              function init(){
                if (GBrowserIsCompatible()) {
                mymap = new  GMap2(document.getElementById('mymap'));
                mymap.setCenter(new GLatLng(43.907787,-79.359741),5);
var marker = createMarker(new GLatLng(10.907787,40.359741),'<b>This is some html!</b>')
mymap.addOverlay(marker)

                }
                // display a warning if the browser was not compatible
                else {
                  alert(\"Sorry, the Google Maps API is not compatible with this browser\");
                }
              }
               //]]>
</script>", @map2.map_javascript
    
  end    
  
  def test_load_function_can_have_head

      jstring = " 
      function createpoly(pointlist) {
          // create poly code goes here
      }

      "

      @map2.add_js(jstring, :as => 'create_poly')

      @point = Mappa::GLatLng.new(:lat => 10.907787, :lng => 40.359741)

      @map2.onload_func[:head] = "
              createPoly();
              "



      assert_equal "<script type=\"text/javascript\">
//  <![CDATA[ 
      function createpoly(pointlist) {
          // create poly code goes here
      }

      

              function init(){
                if (GBrowserIsCompatible()) {
              createPoly();
              
                mymap = new  GMap2(document.getElementById('mymap'));
                mymap.setCenter(new GLatLng(43.907787,-79.359741),5);

                }
                // display a warning if the browser was not compatible
                else {
                  alert(\"Sorry, the Google Maps API is not compatible with this browser\");
                }
              }
               //]]>
</script>", @map2.map_javascript

  end
  def test_load_function_can_have_tail

      jstring = "
      function createpoly(pointlist) {
          // create poly code goes here
      }

      "
      
      @map2.add_js(jstring, :as => 'create_poly')
      
      @point = Mappa::GLatLng.new(:lat => 10.907787, :lng => 40.359741)

      @map2.onload_func[:tail] = "
            createPoly();
            "



      assert_equal "<script type=\"text/javascript\">
//  <![CDATA[
      function createpoly(pointlist) {
          // create poly code goes here
      }

      

              function init(){
                if (GBrowserIsCompatible()) {
                mymap = new  GMap2(document.getElementById('mymap'));
                mymap.setCenter(new GLatLng(43.907787,-79.359741),5);

            createPoly();
            
                }
                // display a warning if the browser was not compatible
                else {
                  alert(\"Sorry, the Google Maps API is not compatible with this browser\");
                }
              }
               //]]>
</script>", @map2.map_javascript

    end    
    
  # should make this one redundant really. We don't want size set from the Mappa module  and i don't think it's useful at the moment.
  def test_should_allow_setting_dimensions_by_size_function()
    # @map = GMap.new()
    @map.size(800,500)
    assert_equal 500, @map.height
    assert_equal 800, @map.width
  end
    
end
