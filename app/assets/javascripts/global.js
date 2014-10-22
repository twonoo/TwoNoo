$(document).ready(function(){
  $('a').bind('click', function(e){
    if ($(this).attr('clicked') == 'true'){
      e.preventDefault();
    }
    $(this).attr('clicked', 'true');
  });
});

var tnl = null;

function TwoNooLocation(city, state) {
  this.city = city;
  this.state = state;
  this.initialized = false;

}

TwoNooLocation.prototype.Init = function()
{
  if (!(this.initialized))
  {
    console.log('Initializing Location');
    tnl = this;

    if (navigator.geolocation)
    {
      console.log('Getting Location');
      navigator.geolocation.getCurrentPosition(this.GetPosition);
      console.log('Got Location');
    }
    this.initialized = true;
  }
}

TwoNooLocation.prototype.GetPosition = function(position) {
        var geocoder = new google.maps.Geocoder();

        var latlng = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
        console.log(latlng);

        geocoder.geocode({'latLng': latlng}, function(results, status){
          $.each(results[0].address_components, function (i, address_component) {
              console.log('address_component:'+i);

              var type = address_component.types[0];
              console.log(i+": "+type+":"+address_component.short_name);

              if (type == 'locality')
                tnl.city = address_component.short_name;
              else if (type == 'administrative_area_level_1')
                tnl.state = address_component.short_name;
          });
          console.log("city, state: "+tnl.city+", "+tnl.state);
        });
      }

TwoNooLocation.prototype.GetLocation = function() {
  this.Init();
  return this.city + ", " + this.state;
}

TwoNooLocation.prototype.GetCity= function()
{
  this.Init();
  return this.city;
}

TwoNooLocation.prototype.GetState = function()
{
  this.Init();
  return this.state;
}
