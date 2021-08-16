<template>
  <div>
    <input
      ref="input"
      class="controls"
      type="text"
      placeholder="Search Box"
    />
  </div>
</template>

<script>
export default {
  name: "Tab2",
  mounted() {
    this.$refs.input.focus();
    const google = window.google;
    const searchBox = new google.maps.places.SearchBox(this.$refs.input);
    searchBox.addListener("places_changed", () => {
      const places = searchBox.getPlaces();

      if (places.length == 0) {
        return;
      }
      console.log(places);
    });
  },
};
</script>