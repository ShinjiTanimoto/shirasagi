this.Member_Photo_Form=function(){function a(){}return a.maxPointForm=10,a.deleteMessage="\u30de\u30fc\u30ab\u30fc\u3092\u524a\u9664\u3057\u3066\u3088\u308d\u3057\u3044\u3067\u3059\u304b\uff1f",a.setExifMessage="\u753b\u50cf\u306b\u4f4d\u7f6e\u60c5\u5831\u304c\u542b\u307e\u308c\u3066\u3044\u307e\u3059\u3002\u4f4d\u7f6e\u60c5\u5831\u3092\u5730\u56f3\u306b\u8a2d\u5b9a\u3057\u307e\u3059\u304b\uff1f",a.dataID=0,a.clickIcon="//maps.google.com/mapfiles/ms/icons/blue-dot.png",a.clickMarker=null,a.setMapLoc=function(a,e,o){e=Math.ceil(e*Math.pow(10,6))/Math.pow(10,6),o=Math.ceil(o*Math.pow(10,6))/Math.pow(10,6),a.val(e.toFixed(6)+","+o.toFixed(6))},a.getMapLoc=function(a){var e;return e=a.val().split(","),new google.maps.LatLng(parseFloat(e[0]),parseFloat(e[1]))},a.attachMessage=function(a){google.maps.event.addListener(Googlemaps_Map.markers[a],"click",function(){Googlemaps_Map.openedInfo&&Googlemaps_Map.openedInfo.close(),$('dd[data-id = "'+a+'"]').each(function(){var e,o,t;return o=$(this).find(".marker-name").val(),t=$(this).find(".marker-text").val(),""===o&&""===t||(e='<div class="marker-info">',""!==o&&(e+="<p>"+o+"</p>"),""!==t&&$.each(t.split(/[\r\n]+/),function(){return this.match(/^https?:\/\//)?e+='<p><a href="'+this+'">'+this+"</a></p>":e+="<p>"+this+"</p>"}),Googlemaps_Map.openedInfo=new google.maps.InfoWindow({content:e,maxWidth:260}),Googlemaps_Map.openedInfo.open(Googlemaps_Map.markers[a].getMap(),Googlemaps_Map.markers[a])),!1})})},a.clearMarker=function(e){var o;o=0,""!==e.val()?confirm(a.deleteMessage)&&Googlemaps_Map.markers[o]&&(Googlemaps_Map.markers[o].setMap(null),e.val("")):Googlemaps_Map.markers[o]&&Googlemaps_Map.markers[o].setMap(null)},a.createMarker=function(e){var o;""!==$(".mod-map .clicked").val()&&(e.val($(".mod-map .clicked").val()),o=0,Googlemaps_Map.markers[o]&&Googlemaps_Map.markers[o].setMap(null),Googlemaps_Map.markers[o]=new google.maps.Marker({position:a.getMapLoc($(".mod-map .marker-loc")),map:Googlemaps_Map.map}),a.attachMessage(o))},a.renderMarkers=function(){var e,o,t,r;if(t=new google.maps.LatLngBounds,Googlemaps_Map.markers)for(e=0,o=(r=Googlemaps_Map.markers).length;e<o;e++)r[e].setMap(null);Googlemaps_Map.markers=[],a.dataID=0,$(".mod-map .marker").each(function(){var e;return $(this).attr("data-id",a.dataID),""!==$(this).find(".marker-loc").val()&&(e=a.getMapLoc($(this).find(".marker-loc")),Googlemaps_Map.markers[a.dataID]=new google.maps.Marker({position:e,map:Googlemaps_Map.map}),a.attachMessage(a.dataID),t.extend(e)),a.dataID+=1}),Googlemaps_Map.markers.length>0&&Googlemaps_Map.map.setCenter(t.getCenter())},a.setExifLatLng=function(e){return $(e).change(function(e){if(e.target.files[0])return EXIF.getData(e.target.files[0],function(){var e,o,t,r;return e=EXIF.getTag(this,"GPSLatitude"),t=EXIF.getTag(this,"GPSLongitude"),o=EXIF.getTag(this,"GPSLatitudeRef")||"N",r=EXIF.getTag(this,"GPSLongitudeRef")||"W",!(!e||!t)&&(!!confirm(a.setExifMessage)&&(o="N"===o?1:-1,r="W"===r?-1:1,e=(e[0]+e[1]/60+e[2]/3600)*o,t=(t[0]+t[1]/60+t[2]/3600)*r,$(".mod-map .clicked").val([e,t].join()),a.createMarker($(".mod-map .marker-loc")),Googlemaps_Map.map.setCenter(new google.maps.LatLng(e,t))))})})},a.renderEvents=function(){google.maps.event.addListener(Googlemaps_Map.map,"click",function(e){return a.setMapLoc($(".mod-map .clicked"),e.latLng.lat(),e.latLng.lng()),a.createMarker($(".mod-map .marker-loc"))}),$(".mod-map .clear-marker").on("click",function(){return a.clearMarker($(".mod-map .marker-loc")),!1}),google.maps.event.addListener(Googlemaps_Map.map,"bounds_changed",function(){var a=Googlemaps_Map.map.getZoom();$('input[name="item[map_zoom_level]"]').val(a)})},a}();