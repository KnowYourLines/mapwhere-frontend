<template>
  <div>
    <input
      ref="input"
      class="controls"
      type="text"
      :value="yourLocation"
      placeholder="Enter location"
      @focus="$event.target.select()"
    /><br /><br /><img
      src="@/assets/icons8-location-off-50.png"
      @click="getCurrentLocation"
      class="tab-button"
      width="25"
    />
    <div v-if="noLocationFound"><br />No location found.</div>
    <div v-if="possiblePlaces">
      <ul id="array-rendering">
        Did you mean:
        <br /><br />
        <li v-for="place in possiblePlaces" :key="place.place_id">
          <button type="button" class="btn" @click="selectLocation(place)">
            {{ place.name }}<br />
            {{ place.formatted_address }}</button
          ><br /><br />
        </li>
      </ul>
    </div>
  </div>
</template>

<script>
export default {
  name: "Tab2",
  data() {
    return {
      lat: null,
      lng: null,
      possiblePlaces: null,
      yourLocation: null,
      noLocationFound: false,
    };
  },
  methods: {
    selectLocation: function (place) {
      this.lat = place.geometry.location.lat();
      this.lng = place.geometry.location.lng();
      this.yourLocation = place.name + ", " + place.formatted_address;
      this.possiblePlaces = null;
    },
    getCurrentLocation: function () {
      if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition((position) => {
          const geocoder = new this.google.maps.Geocoder();
          const latlng = {
            lat: parseFloat(position.coords.latitude),
            lng: parseFloat(position.coords.longitude),
          };
          geocoder.geocode({ location: latlng }).then((response) => {
            console.log(response);
            if (response.results.length > 0) {
              const foundLocation = response.results[0];
              this.yourLocation = foundLocation.formatted_address;
              this.lat = foundLocation.geometry.location.lat();
              this.lng = foundLocation.geometry.location.lng();
              this.possiblePlaces = null;
            }
          });
        });
      } else {
        alert("Your browser doesn't support geolocation.");
      }
    },
  },
  mounted() {
    this.$refs.input.focus();
    this.google = window.google;
    const searchBox = new this.google.maps.places.SearchBox(this.$refs.input);
    searchBox.addListener("places_changed", () => {
      const places = searchBox.getPlaces();

      if (places.length == 0) {
        this.possiblePlaces = null;
        this.noLocationFound = true;
        console.log("no location found");
      }

      if (places.length == 1) {
        console.log(places[0].geometry.location.lat());
        console.log(places[0].geometry.location.lng());
        console.log(places);

        this.lng = places[0].geometry.location.lng();
        this.lat = places[0].geometry.location.lat();
        this.yourLocation = places[0].name + ", " + places[0].formatted_address;
        this.possiblePlaces = null;
        this.noLocationFound = false;
      }

      if (places.length > 1) {
        this.possiblePlaces = places;
        this.noLocationFound = false;
        console.log(places);
      }
    });
  },
};
</script>

<style >
#array-rendering {
  list-style-type: none;
}
</style>
