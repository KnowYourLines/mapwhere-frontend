<template>
  <div>
    <br />
    <img
      src="@/assets/icons8-location-off-50.png"
      @click="getCurrentLocation"
      class="tab-button"
      width="25"
    /><br />
    <input
      ref="input"
      class="controls"
      type="text"
      :value="yourLocation"
      placeholder="Enter start location"
      @focus="$event.target.select()"
    /><br /><br />

    <div v-if="noLocationFound"><br />No location found.</div>
    <div v-if="possiblePlaces">
      <ul id="array-rendering">
        Did you mean:
        <br /><br />
        <li>
          <button type="button" class="btn" @click="allLocationsWrong">
            None of these</button
          ><br /><br />
        </li>
        <li v-for="place in possiblePlaces" :key="place.place_id">
          <button type="button" class="btn" @click="selectLocation(place)">
            {{ place.name }}<br />
            {{ place.formatted_address }}</button
          ><br /><br />
        </li>
      </ul>
    </div>
    <div v-else>
      <img
        src="@/assets/icons8-public-transportation-50.png"
        v-bind:class="{ active: travelMode === 'transit' }"
        @click="travelMode = 'transit'"
        class="tab-button"
        width="25"
      /><img
        src="@/assets/icons8-walking-50.png"
        v-bind:class="{ active: travelMode === 'walk' }"
        @click="travelMode = 'walk'"
        class="tab-button"
        width="25"
      /><img
        src="@/assets/icons8-cycling-100.png"
        v-bind:class="{ active: travelMode === 'bike' }"
        @click="travelMode = 'bike'"
        class="tab-button"
        width="25"
      />
      <img
        src="@/assets/icons8-car-60.png"
        v-bind:class="{ active: travelMode === 'car' }"
        @click="travelMode = 'car'"
        class="tab-button"
        width="25"
      /><br />
      <div id="time-form">
        <input
          type="number"
          v-model.number.lazy="hoursToTravel"
          min="0"
          @focus="$event.target.select()"
        /><label> hours </label>
        <input
          type="number"
          min="0"
          v-model.number.lazy="minutesToTravel"
          @focus="$event.target.select()"
        /><label> minutes</label>
      </div>
      <br />
      <button type="button" class="btn" @click="updateIsochrone">
        Find reachable area
      </button>
    </div>
  </div>
</template>

<script>
export default {
  name: "Tab2",
  emits: ["goto-area-tab"],
  data() {
    return {
      lat: null,
      lng: null,
      possiblePlaces: null,
      yourLocation: null,
      noLocationFound: false,
      travelMode: "transit",
      hoursToTravel: 0,
      minutesToTravel: 0,
    };
  },
  methods: {
    allLocationsWrong: function () {
      this.possiblePlaces = null;
    },
    updateIsochrone: function () {
      this.$emit("goto-area-tab");
      console.log("send something over the websocket");
    },
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
.tab-button {
  padding: 6px 10px;
  border-top-left-radius: 3px;
  border-top-right-radius: 3px;
  border: 1px solid #ccc;
  cursor: pointer;
  background: #f0f0f0;
  margin-bottom: -1px;
  margin-right: -1px;
}
.tab-button:hover {
  background: #e0e0e0;
}
.tab-button.active {
  background: #e0e0e0;
}
#time-form {
  white-space: pre;
  display: flex;
  align-items: center;
  justify-content: center;
}
</style>
