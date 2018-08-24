this.Openlayers_Member_Photo_Form=function(){function e(e,r){null==r&&(r={}),this.canvas=e,this.opts=r,this.markerFeature=null,this.markerLayer=null,this.popup=null,this.maxPointForm=10,this.deleteMessage="\u30de\u30fc\u30ab\u30fc\u3092\u524a\u9664\u3057\u3066\u3088\u308d\u3057\u3044\u3067\u3059\u304b\uff1f",this.setExifMessage="\u753b\u50cf\u306b\u4f4d\u7f6e\u60c5\u5831\u304c\u542b\u307e\u308c\u3066\u3044\u307e\u3059\u3002\u4f4d\u7f6e\u60c5\u5831\u3092\u5730\u56f3\u306b\u8a2d\u5b9a\u3057\u307e\u3059\u304b\uff1f",this.dataID=0,this.markerIcon="/assets/img/map-marker.png",this.clickIcon="/assets/img/map-marker-click.png",this.clickMarkerId=null,this.render()}return e.prototype.getMapLoc=function(e){var r;return r=e.val().split(","),[parseFloat(r[0]),parseFloat(r[1])]},e.prototype.setMapLoc=function(e,r,t){r=Math.ceil(r*Math.pow(10,6))/Math.pow(10,6),t=Math.ceil(t*Math.pow(10,6))/Math.pow(10,6),e.val(r.toFixed(6)+","+t.toFixed(6))},e.prototype.render=function(){return this.initMap(),this.renderMarkers(),this.resize(),this.renderEvents()},e.prototype.createLayers=function(e){var r,t,a,o,n,i,s,c;for(a=[],r=0,o=e.length;r<o;r++)s=(n=e[r]).source,c=n.url,i=n.projection,t=new ol.layer.Tile({source:new ol.source[s]({url:c,projection:i})}),a.push(t);return a},e.prototype.initMap=function(){var e,r;return e=this.opts.center||[138.252924,36.204824],(r=this.opts.layers)||(r=[{source:"XYZ",url:"http://cyberjapandata.gsi.go.jp/xyz/std/{z}/{x}/{y}.png",projection:"EPSG:3857"}]),this.map=new ol.Map({target:this.canvas,renderer:["canvas","dom"],layers:this.createLayers(r),controls:ol.control.defaults({attributionOptions:{collapsible:!1}}),view:new ol.View({projection:"EPSG:3857",center:ol.proj.transform(e,"EPSG:4326","EPSG:3857"),maxZoom:18,zoom:this.opts.zoom||10}),logo:!1})},e.prototype.setCenter=function(e){var r;return r=[e[1],e[0]],this.map.getView().setCenter(ol.proj.transform(r,"EPSG:4326","EPSG:3857"))},e.prototype.renderMarkers=function(){return $(".mod-map .marker").each((e=this,function(r,t){var a;return $(t).attr("data-id",e.dataID),""!==$(t).find(".marker-loc").val()&&(a=e.getMapLoc($(t).find(".marker-loc")),e.setMarker(a,{id:parseInt(e.dataID)})),e.dataID+=1}));var e},e.prototype.setMarker=function(e,r){var t,a,o,n,i,s,c;return null==r&&(r={}),s=this.markerIcon,r.image&&(s=r.image),c=new ol.style.Style({image:new ol.style.Icon({anchor:[.5,1],anchorXUnits:"fraction",anchorYUnits:"fraction",src:s})}),a=[e[1],e[0]],(t=new ol.Feature({geometry:new ol.geom.Point(ol.proj.transform(a,"EPSG:4326","EPSG:3857")),markerId:null!=(o=r.id)?o:null,markerHtml:null!=(n=r.html)?n:null,category:null!=(i=r.category)?i:null})).setStyle(c),this.markerLayer?(console.log(this.markerLayer.getSource()),this.markerLayer.getSource().addFeature(t)):(this.markerLayer=new ol.layer.Vector({source:new ol.source.Vector({features:[t]})}),this.map.addLayer(this.markerLayer)),t},e.prototype.getMarker=function(e){var r;return r=null,this.markerLayer?(this.markerLayer.getSource().forEachFeature(function(t){if(t.get("markerId")===e)return r=t}),r):r},e.prototype.removeMarker=function(e){var r;return!!(r=this.getMarker(e))&&(this.markerLayer.getSource().removeFeature(r),!0)},e.prototype.renderEvents=function(){var e;return this.map.on("click",(e=this,function(r){var t;for(e.map.forEachFeatureAtPixel(r.pixel,function(e){return e}),t=ol.proj.transform(r.coordinate,"EPSG:3857","EPSG:4326");t[0]<180;)t[0]+=360;for(;t[0]>180;)t[0]-=360;return t.reverse(),e.setMapLoc($(".mod-map .clicked"),t[0],t[1]),e.setMapLoc($(".mod-map .marker-loc"),t[0],t[1]),console.log(),e.createMarker($(".mod-map .marker-loc"))})),this.map.getView().on("propertychange",function(e){if("resolution"===e.key){var r=this.getZoom();$('input[name="item[map_zoom_level]"]').val(r)}}),$(".mod-map .clear-marker").on("click",function(e){return function(){return e.clearMarker($(".mod-map .marker-loc")),!1}}(this))},e.prototype.createMarker=function(e){var r;return r=0,this.removeMarker(r),this.setMarker(this.getMapLoc(e),{id:r})},e.prototype.clearMarker=function(e){var r;r=0,""!==e.val()?confirm(this.deleteMessage)&&(this.removeMarker(r),e.val("")):this.removeMarker(r)},e.prototype.setExifLatLng=function(e){return $(e).change((r=this,function(e){var t;if(e.target.files[0])return t=r,EXIF.getData(e.target.files[0],function(){var e,r,a,o;return e=EXIF.getTag(this,"GPSLatitude"),a=EXIF.getTag(this,"GPSLongitude"),r=EXIF.getTag(this,"GPSLatitudeRef")||"N",o=EXIF.getTag(this,"GPSLongitudeRef")||"W",!(!e||!a)&&!!confirm(t.setExifMessage)&&(r="N"===r?1:-1,o="W"===o?-1:1,e=(e[0]+e[1]/60+e[2]/3600)*r,a=(a[0]+a[1]/60+a[2]/3600)*o,$(".mod-map .clicked").val([e,a].join()),$(".mod-map .marker-loc").val([e,a].join()),t.createMarker($(".mod-map .marker-loc")),t.setCenter([e,a]))})}));var r},e.prototype.resize=function(){var e;this.markerLayer&&(e=this.markerLayer.getSource().getExtent(),this.map.getView().setCenter(ol.extent.getCenter(e)))},e}();