<template>
  <div class="column">
    <div v-if="missingLocations">
      <br />
      <span>Missing user locations for:<br /><br /></span>
      <div id="array-rendering">
        <span v-for="user in usersMissingLocations" :key="user.username">
          {{ user.display_name }}
          <br />
        </span>
      </div>
    </div>
    <div v-if="!missingArea">
      <br />
      <input
        ref="queryInput"
        type="text"
        v-model.trim="query"
        placeholder="Search area for..."
        @keyup.enter="submitAreaQuery"
        @focus="$event.target.select()"
      />
      <div id="map" ref="map"></div>
      <div style="display: none">
        <div ref="infoContent" id="info-content">
          <table>
            <tr ref="iwUrlRow" id="iw-url-row" class="iw_table_row">
              <td ref="iwIcon" id="iw-icon" class="iw_table_icon">
                <img ref="icon" />
              </td>
              <td ref="iwURL" id="iw-url">
                <b
                  ><a
                    ref="mapsURL"
                    target="_blank"
                    rel="noopener noreferrer"
                  ></a
                ></b>
              </td>
            </tr>
            <tr ref="iwAddressRow" id="iw-address-row" class="iw_table_row">
              <td class="iw_attribute_name">Address:</td>
              <td ref="iwAddress" id="iw-address"></td>
            </tr>
            <tr ref="iwPhoneRow" id="iw-phone-row" class="iw_table_row">
              <td class="iw_attribute_name">Telephone:</td>
              <td ref="iwPhone" id="iw-phone"></td>
            </tr>
            <tr ref="iwRatingRow" id="iw-rating-row" class="iw_table_row">
              <td class="iw_attribute_name">Rating:</td>
              <td ref="iwRating" id="iw-rating"></td>
            </tr>
          </table>
          <div ref="iwWebsiteRow" id="iw-website-row" class="iw_table_row">
            <div ref="iwWebsite" id="iw-website">
              <b
                ><a
                  ref="websiteURL"
                  target="_blank"
                  rel="noopener noreferrer"
                ></a
              ></b>
              <br /><br />
            </div>
          </div>
          <br />
          <button type="submit" class="btn btn__primary" @click="savePlace">
            Save place
          </button>
        </div>
      </div>
      <div ref="list">
        <div
          v-if="placeResults.length"
          @scroll="onScroll"
          ref="listing"
          id="listing"
        >
          <table class="listing-table">
            <tbody>
              <tr
                class="results"
                @click="selectedResult(index)"
                v-for="(result, index) in placeResults"
                :key="index"
                v-bind:class="{ active: selectedResultIndex === index }"
              >
                <td><img :src="result.icon" /></td>
                <td>{{ result.name }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    <div v-else ref="noArea"><br />No area found. Try to travel further.</div>
  </div>
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
    areaQueryResults: {
      type: Array,
      required: true,
    },
    areaQuery: {
      type: String,
      required: false,
    },
    nextPagePlacesToken: {
      type: String,
      required: true,
    },
    nextPagePlaces: {
      type: Array,
      required: true,
    },
  },
  data() {
    return {
      missingArea: false,
      missingLocations: false,
      placeResults: [],
      selectedResultIndex: null,
      markers: [],
      query: this.areaQuery,
    };
  },
  watch: {
    nextPagePlaces: function (newPlaces) {
      if (newPlaces.length > 0) {
        let startIndex = this.placeResults.length - 1;
        this.placeResults = this.placeResults.concat(newPlaces);
        for (let i = startIndex; i < this.placeResults.length; i++) {
          // Use marker animation to drop the icons incrementally on the map.
          this.markers[i] = new window.google.maps.Marker({
            position: this.placeResults[i].geometry.location,
            animation: window.google.maps.Animation.DROP,
          });
          // If the user clicks a marker, show the details in an info window.
          this.markers[i].placeResult = this.placeResults[i];
          window.google.maps.event.addListener(
            this.markers[i],
            "click",
            function () {
              const marker = this.markers[i];
              let place = this.placeResults[i];
              const request = {
                placeId: place.place_id,
                fields: [
                  "url",
                  "formatted_phone_number",
                  "place_id",
                  "website",
                  "vicinity",
                ],
              };
              const service = new window.google.maps.places.PlacesService(
                this.map
              );
              service.getDetails(request, (result, status) => {
                if (
                  status === window.google.maps.places.PlacesServiceStatus.OK
                ) {
                  place.website = result.website;
                  place.vicinity = result.vicinity;
                  this.placeResults[i].place_id = result.place_id;
                  place.formatted_phone_number = result.formatted_phone_number;
                  place.url = result.url;
                  this.selectedResultIndex = i;
                  this.infoWindow.open(this.map, marker);

                  this.$refs.icon.src = place.icon;
                  this.$refs.mapsURL.href = place.url;
                  this.$refs.mapsURL.textContent = place.name;
                  this.$refs.iwAddress.textContent = place.vicinity;

                  if (place.formatted_phone_number) {
                    this.$refs.iwPhoneRow.style.display = "";
                    this.$refs.iwPhone.textContent =
                      place.formatted_phone_number;
                  } else {
                    this.$refs.iwPhoneRow.style.display = "none";
                  }

                  if (place.rating) {
                    let ratingHtml = "";

                    for (let i = 0; i < 5; i++) {
                      if (place.rating < i + 0.5) {
                        ratingHtml += "&#10025;";
                      } else {
                        ratingHtml += "&#10029;";
                      }
                      this.$refs.iwRatingRow.style.display = "";
                      this.$refs.iwRating.innerHTML = ratingHtml;
                    }
                  } else {
                    this.$refs.iwRatingRow.style.display = "none";
                  }

                  if (place.website) {
                    this.$refs.iwWebsiteRow.style.display = "";
                    this.$refs.websiteURL.href = place.website;
                    this.$refs.websiteURL.textContent = "Go to website";
                  } else {
                    this.$refs.iwWebsiteRow.style.display = "none";
                  }
                }
              });
            }.bind(this)
          );
          setTimeout(
            function () {
              if (this.markers[i]) {
                this.markers[i].setMap(this.map);
              }
            }.bind(this),
            i
          );
        }
      }
    },
    area: function () {
      if (
        this.area.type &&
        this.area.coordinates &&
        this.area.centroid_lat &&
        this.area.centroid_lng
      ) {
        this.missingArea = false;
      } else {
        this.missingArea = true;
      }
      if (!this.missingArea) {
        if (!this.$refs.map) {
          this.$nextTick(() => {
            this.map = new window.google.maps.Map(this.$refs.map, {
              zoom: 14,
              center: {
                lat: this.area.centroid_lat,
                lng: this.area.centroid_lng,
              },
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
            this.map.data.addGeoJson(geoJson);
            if (this.query) {
              this.submitAreaQuery();
            }
          });
        } else {
          this.map = new window.google.maps.Map(this.$refs.map, {
            zoom: 14,
            center: {
              lat: this.area.centroid_lat,
              lng: this.area.centroid_lng,
            },
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
          this.map.data.addGeoJson(geoJson);
          if (this.query) {
            this.submitAreaQuery();
          }
        }
      }
    },
    areaQueryResults: function () {
      this.infoWindow = new window.google.maps.InfoWindow({
        content: this.$refs.infoContent,
      });
      window.google.maps.event.addListener(
        this.infoWindow,
        "closeclick",
        function () {
          this.selectedResultIndex = null;
        }.bind(this)
      );
      for (let i = 0; i < this.markers.length; i++) {
        if (this.markers[i]) {
          this.markers[i].setMap(null);
        }
      }
      if (
        this.area.type &&
        this.area.coordinates &&
        this.area.centroid_lat &&
        this.area.centroid_lng
      ) {
        this.missingArea = false;
      } else {
        this.missingArea = true;
      }
      if (!this.missingArea) {
        this.map = new window.google.maps.Map(this.$refs.map, {
          zoom: 14,
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
        this.map.data.addGeoJson(geoJson);
      }
      this.markers = [];
      this.selectedResultIndex = null;
      this.placeResults = this.areaQueryResults;
      if (this.placeResults.length == 0) {
        alert("No places found!");
      } else {
        for (let i = 0; i < this.placeResults.length; i++) {
          // Use marker animation to drop the icons incrementally on the map.
          this.markers[i] = new window.google.maps.Marker({
            position: this.placeResults[i].geometry.location,
            animation: window.google.maps.Animation.DROP,
          });
          // If the user clicks a marker, show the details in an info window.
          this.markers[i].placeResult = this.placeResults[i];
          window.google.maps.event.addListener(
            this.markers[i],
            "click",
            function () {
              const marker = this.markers[i];
              let place = this.placeResults[i];
              const request = {
                placeId: place.place_id,
                fields: [
                  "url",
                  "formatted_phone_number",
                  "place_id",
                  "website",
                  "vicinity",
                ],
              };
              const service = new window.google.maps.places.PlacesService(
                this.map
              );
              service.getDetails(request, (result, status) => {
                if (
                  status === window.google.maps.places.PlacesServiceStatus.OK
                ) {
                  place.website = result.website;
                  place.vicinity = result.vicinity;
                  this.placeResults[i].place_id = result.place_id;
                  place.formatted_phone_number = result.formatted_phone_number;
                  place.url = result.url;
                  this.selectedResultIndex = i;
                  this.infoWindow.open(this.map, marker);

                  this.$refs.icon.src = place.icon;
                  this.$refs.mapsURL.href = place.url;
                  this.$refs.mapsURL.textContent = place.name;
                  this.$refs.iwAddress.textContent = place.vicinity;

                  if (place.formatted_phone_number) {
                    this.$refs.iwPhoneRow.style.display = "";
                    this.$refs.iwPhone.textContent =
                      place.formatted_phone_number;
                  } else {
                    this.$refs.iwPhoneRow.style.display = "none";
                  }

                  if (place.rating) {
                    let ratingHtml = "";

                    for (let i = 0; i < 5; i++) {
                      if (place.rating < i + 0.5) {
                        ratingHtml += "&#10025;";
                      } else {
                        ratingHtml += "&#10029;";
                      }
                      this.$refs.iwRatingRow.style.display = "";
                      this.$refs.iwRating.innerHTML = ratingHtml;
                    }
                  } else {
                    this.$refs.iwRatingRow.style.display = "none";
                  }

                  if (place.website) {
                    this.$refs.iwWebsiteRow.style.display = "";
                    this.$refs.websiteURL.href = place.website;
                    this.$refs.websiteURL.textContent = "Go to website";
                  } else {
                    this.$refs.iwWebsiteRow.style.display = "none";
                  }
                }
              });
            }.bind(this)
          );
          setTimeout(
            function () {
              if (this.markers[i]) {
                this.markers[i].setMap(this.map);
              }
            }.bind(this),
            i
          );
        }
        this.$nextTick(() => {
          this.$refs.list.scrollIntoView({
            behavior: "smooth",
            block: "end",
            inline: "nearest",
          });
        });
      }
    },
  },
  methods: {
    savePlace: function () {
      let placeToSave = this.placeResults[this.selectedResultIndex];
      let placeId = placeToSave.place_id;
      let placeLng = placeToSave.geometry.location.lng;
      let placeLat = placeToSave.geometry.location.lat;
      this.socketRef.send(
        JSON.stringify({
          command: "save_place",
          lat: placeLat,
          lng: placeLng,
          id: placeId,
        })
      );
    },
    selectedResult: function (index) {
      this.selectedResultIndex = null;
      this.selectedResultIndex = index;
      window.google.maps.event.trigger(this.markers[index], "click");
    },
    submitAreaQuery: function () {
      const turf = window.turf;
      let bbox;
      let center = turf.point([this.area.centroid_lng, this.area.centroid_lat]);
      let searchRadius;

      if (this.area.type == "Polygon") {
        this.intersection = turf.polygon(this.area.coordinates);
      }
      if (this.area.type == "MultiPolygon") {
        this.intersection = turf.multiPolygon(this.area.coordinates);
      }
      bbox = turf.bbox(this.intersection);
      searchRadius = Math.max(
        turf.distance(center, turf.point([bbox[0], bbox[1]])) * 1000,
        turf.distance(center, turf.point([bbox[2], bbox[3]])) * 1000
      );
      this.socketRef.send(
        JSON.stringify({
          command: "update_area_query",
          query: this.query,
          radius: searchRadius,
          lat: this.area.centroid_lat,
          lng: this.area.centroid_lng,
        })
      );
    },
    onScroll: function ({ target: { scrollTop, clientHeight, scrollHeight } }) {
      if (
        scrollHeight == Math.round(scrollTop + clientHeight) &&
        this.nextPagePlacesToken &&
        this.$refs.list.getBoundingClientRect().bottom <=
          scrollTop + clientHeight
      ) {
        this.socketRef.send(
          JSON.stringify({
            command: "get_next_page_places",
            token: this.nextPagePlacesToken,
          })
        );
      }
    },
  },
  beforeUpdate() {
    if (
      this.area.type &&
      this.area.coordinates &&
      this.area.centroid_lat &&
      this.area.centroid_lng
    ) {
      this.missingArea = false;
    } else {
      this.missingArea = true;
    }
    if (this.usersMissingLocations.length > 0) {
      this.missingLocations = true;
    } else {
      this.missingLocations = false;
    }
  },
  mounted() {
    if (this.$refs.query) {
      this.$refs.queryInput.focus();
    }
  },
};
</script>

<style scoped >
#array-rendering {
  height: 10vh;
  overflow-y: auto;
  overflow-x: visible;
}
#map {
  height: 80vh;
}

#listing {
  height: 30vh;
  overflow-y: auto;
  overflow-x: visible;
}
.listing-table {
  display: table;
  width: 100%;
}

.results:nth-child(odd) {
  background-color: rgb(227, 246, 255);
}
.results:hover {
  background: #e0e0e0;
}
.results.active {
  background: #e0e0e0;
}
@media (orientation: portrait) {
  .column {
    display: inline-block;
    width: 100%;
    padding-bottom: 1em;
  }
}
</style>