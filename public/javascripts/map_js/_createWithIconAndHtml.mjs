function createMarker(point,html,icon_image) {
              var icon = new GIcon();

              icon.image =   icon_image  ;

              icon.shadow = "http://labs.google.com/ridefinder/images/mm_20_shadow.png";
              icon.iconSize = new GSize(12, 20);
              icon.shadowSize = new GSize(22, 20);
              icon.iconAnchor = new GPoint(6, 20);
              icon.infoWindowAnchor = new GPoint(5, 1);

              var marker = new GMarker(point,icon);

              GEvent.addListener(marker, "click", function() {
                marker.openInfoWindowHtml(html);
              });
            return marker;
          }