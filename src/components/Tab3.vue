<template>
  <div id="map" ref="map"></div>
</template>

<script>
export default {
  name: "Tab3",
  props: {
    socketRef: {
      type: WebSocket,
      required: false,
    },
    area: {
      type: Object,
      required: true,
    },
    usersMissingLocations: {
      type: Array,
      required: true,
    },
  },
  mounted() {
    const map = new window.google.maps.Map(this.$refs.map, {
      zoom: 15,
      center: { lat: this.area.centroid_lat, lng: this.area.centroid_lng },
    });
    const geoJson = {
      type: "FeatureCollection",
      features: [
        {
          type: "Feature",
          geometry: {
            type: this.area.type,
            coordinates: this.area.coordinates,
          },
        },
      ],
    };
    map.data.addGeoJson(geoJson);
  },
};
</script>

<style >
#map {
  height: 100vh;
}
</style>