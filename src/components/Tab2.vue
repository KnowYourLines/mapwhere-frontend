<template>
  <div>
    <input
      ref="input"
      class="controls"
      type="text"
      :value="yourLocation"
      placeholder="Your location"
      @focus="$event.target.select()"
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
  },
  mounted() {
    this.$refs.input.focus();
    const google = window.google;
    const searchBox = new google.maps.places.SearchBox(this.$refs.input);
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
