<template>
  <div>
    <div v-if="flagMissingOwnLocation"><br />Missing your location!</div>
    <br />

    <img
      src="@/assets/icons8-location-off-50.png"
      @click="getCurrentLocation"
      class="tab-button"
      width="25"
    /><br />
    <input
      ref="location"
      class="controls"
      type="text"
      :value="yourLocation"
      placeholder="Enter start location"
      @keyup.enter="$refs.location.value = yourLocation"
      @focus="$event.target.select()"
    />
    <div v-if="noLocationFound"><br />No location found.</div>
    <br /><br />

    <div v-if="possiblePlaces">
      Did you mean:
      <br /><br />
      <span>
        <button type="button" class="btn" @click="allLocationsWrong">
          None of these</button
        ><br /><br />
      </span>
      <div id="array-rendering">
        <span v-for="place in possiblePlaces" :key="place.place_id">
          <button type="button" class="btn" @click="selectLocation(place)">
            {{ place.name }}<br />
            {{ place.formatted_address }}</button
          ><br /><br />
        </span>
      </div>
    </div>
    <div v-else>
      <img
        v-if="
          isochroneServiceRegion !== 'africa' &&
          isochroneServiceRegion !== 'central_america'
        "
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
      <div>
        <input
          ref="hours"
          type="number"
          v-model.number.lazy="hoursToTravel"
          min="0"
          @focus="$event.target.select()"
        /><br /><label> hours </label><br />
        <input
          ref="minutes"
          type="number"
          min="0"
          v-model.number.lazy="minutesToTravel"
          @focus="$event.target.select()"
        /><br /><label> minutes</label>
      </div>
      <br />
      <button type="button" class="btn" @click="updateLocationBubble">
        Find reachable area
      </button>
    </div>
  </div>
</template>

<script>
export default {
  name: "Tab2",
  props: {
    socketRef: {
      type: WebSocket,
      required: false,
    },
    locationBubble: {
      type: Object,
      required: true,
    },
    isochroneServiceRegion: {
      type: String,
      required: false,
    },
    user: {
      type: Object,
      required: true,
    },
    usersMissingLocations: {
      type: Array,
      required: true,
    },
  },
  data() {
    return {
      lat: null,
      lng: null,
      possiblePlaces: null,
      yourLocation: null,
      noLocationFound: false,
      travelMode: "walk",
      hoursToTravel: 0,
      minutesToTravel: 0,
      flagMissingOwnLocation: false,
      placeId: null,
    };
  },
  watch: {
    isochroneServiceRegion: function (newRegion) {
      if (
        (newRegion == "africa" || newRegion == "central_america") &&
        this.travelMode == "transit"
      ) {
        this.travelMode = "walk";
      }
    },
  },
  methods: {
    allLocationsWrong: function () {
      this.possiblePlaces = null;
    },
    updateLocationBubble: function () {
      if (!this.yourLocation) {
        alert("Enter a starting location!");
      } else if (
        parseFloat(this.minutesToTravel) < 0 ||
        !Number.isInteger(parseFloat(this.minutesToTravel))
      ) {
        alert("Minutes must be a non-negative whole number!");
      } else if (
        parseFloat(this.hoursToTravel) < 0 ||
        !Number.isInteger(parseFloat(this.hoursToTravel))
      ) {
        alert("Hours must be a non-negative whole number!");
      } else if (
        parseFloat(this.minutesToTravel) == 0 &&
        parseFloat(this.hoursToTravel) == 0
      ) {
        alert("Total travel time cannot be zero!");
      } else if (
        parseFloat(this.minutesToTravel) * 60 +
          parseFloat(this.hoursToTravel) * 3600 >
        7200
      ) {
        alert("Total travel time cannot be more than 2 hours!");
      } else {
        this.socketRef.send(
          JSON.stringify({
            command: "update_location_bubble",
            address: this.yourLocation,
            latitude: this.lat,
            longitude: this.lng,
            transportation: this.travelMode,
            hours: this.hoursToTravel,
            minutes: this.minutesToTravel,
            place_id: this.placeId,
          })
        );
      }
    },
    selectLocation: function (place) {
      this.lat = place.geometry.location.lat();
      this.lng = place.geometry.location.lng();
      this.placeId = place.place_id;
      this.yourLocation = place.name + ", " + place.formatted_address;
      this.possiblePlaces = null;
      this.socketRef.send(
        JSON.stringify({
          command: "get_isochrone_service_region",
          latitude: this.lat,
          longitude: this.lng,
        })
      );
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
            if (response.results.length > 0) {
              const foundLocation = response.results[0];
              this.yourLocation = foundLocation.formatted_address;
              this.lat = foundLocation.geometry.location.lat();
              this.placeId = foundLocation.place_id;
              this.lng = foundLocation.geometry.location.lng();
              this.possiblePlaces = null;
              this.socketRef.send(
                JSON.stringify({
                  command: "get_isochrone_service_region",
                  latitude: this.lat,
                  longitude: this.lng,
                })
              );
            }
          });
        });
      } else {
        alert("Your browser doesn't support geolocation.");
      }
    },
  },
  mounted() {
    this.usersMissingLocations.forEach((user) => {
      if (user.username == this.user.uid) {
        this.flagMissingOwnLocation = true;
      }
    });
    this.google = window.google;
    const searchBox = new this.google.maps.places.SearchBox(
      this.$refs.location
    );
    searchBox.addListener("places_changed", () => {
      const places = searchBox.getPlaces();

      if (places.length == 0) {
        this.possiblePlaces = null;
        this.noLocationFound = true;
      }

      if (places.length == 1) {
        this.lng = places[0].geometry.location.lng();
        this.lat = places[0].geometry.location.lat();
        this.placeId = places[0].place_id;
        if (places[0].formatted_address.includes(places[0].name)) {
          this.yourLocation = places[0].formatted_address;
        } else {
          this.yourLocation =
            places[0].name + ", " + places[0].formatted_address;
        }

        this.possiblePlaces = null;
        this.noLocationFound = false;
        this.socketRef.send(
          JSON.stringify({
            command: "get_isochrone_service_region",
            latitude: this.lat,
            longitude: this.lng,
          })
        );
      }

      if (places.length > 1) {
        this.possiblePlaces = places;
        this.noLocationFound = false;
      }
    });
  },
  beforeUpdate() {
    if (
      this.locationBubble.address &&
      this.locationBubble.latitude &&
      this.locationBubble.longitude &&
      this.locationBubble.hours + this.locationBubble.minutes > 0 &&
      !this.yourLocation &&
      !this.lat &&
      !this.lng &&
      !this.hoursToTravel &&
      !this.minutesToTravel
    ) {
      this.yourLocation = this.locationBubble.address;
      this.lat = this.locationBubble.latitude;
      this.placeId = this.locationBubble.place_id;
      this.lng = this.locationBubble.longitude;
      this.travelMode = this.locationBubble.transportation;
      this.hoursToTravel = this.locationBubble.hours;
      this.minutesToTravel = this.locationBubble.minutes;
    }
    this.flagMissingOwnLocation = false;
    this.usersMissingLocations.forEach((user) => {
      if (user.username == this.user.uid) {
        this.flagMissingOwnLocation = true;
      }
    });
  },
};
</script>

<style >
#array-rendering {
  height: 30vh;
  overflow-y: auto;
  overflow-x: visible;
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
</style>
