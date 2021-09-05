<template>
  <div>
    <div v-if="missingLocations">
      <ul id="array-rendering">
        <span>Missing user locations for:</span>
        <li v-for="user in usersMissingLocations" :key="user.username">
          {{ user.display_name }}
          <br />
        </li>
      </ul>
    </div>
    <div v-if="!missingArea">
      <div id="v-model-select-dynamic" class="demo">
        <br />
        <select v-model="selected" @change="placeTypeSelected">
          <option :value="null" selected disabled hidden>Look for...</option>
          <option
            v-for="option in options"
            :value="option.value"
            :key="option.value"
          >
            {{ option.text }}
          </option>
        </select>
      </div>
      <div id="map" ref="map"></div>
      <div ref="listing" id="listing">
        <table ref="resultsTable" id="resultsTable">
          <tbody ref="results" id="results"></tbody>
        </table>
      </div>

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
            <tr ref="iwWebsiteRow" id="iw-website-row" class="iw_table_row">
              <td class="iw_attribute_name">Website:</td>
              <td ref="iwWebsite" id="iw-website">
                <b
                  ><a
                    ref="websiteURL"
                    target="_blank"
                    rel="noopener noreferrer"
                  ></a
                ></b>
              </td>
            </tr>
          </table>
        </div>
      </div>
    </div>
    <div v-else ref="noArea">No area found. Try to travel further.</div>
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
  },
  data() {
    return {
      missingArea: false,
      missingLocations: false,
      selected: null,
      options: [
        { text: "Accounting", value: "accounting" },
        { text: "Airport", value: "airport" },
        { text: "Amusement Park", value: "amusement_park" },
        { text: "Aquarium", value: "aquarium" },
        { text: "Art Gallery", value: "art_gallery" },
        { text: "ATM", value: "atm" },
        { text: "Bakery", value: "bakery" },
        { text: "Bank", value: "bank" },
        { text: "Bar", value: "bar" },
        { text: "Beauty Salon", value: "beauty_salon" },
        { text: "Bicycle Store", value: "bicycle_store" },
        { text: "Book Store", value: "book_store" },
        { text: "Bowling Alley", value: "bowling_alley" },
        { text: "Bus Station", value: "bus_station" },
        { text: "Cafe", value: "cafe" },
        { text: "Campground", value: "campground" },
        { text: "Car Dealer", value: "car_dealer" },
        { text: "Car Rental", value: "car_rental" },
        { text: "Car Repair", value: "car_repair" },
        { text: "Car Wash", value: "car_wash" },
        { text: "Casino", value: "casino" },
        { text: "Cemetery", value: "cemetery" },
        { text: "Church", value: "church" },
        { text: "City Hall", value: "city_hall" },
        { text: "Clothing Store", value: "clothing_store" },
        { text: "Convenience Store", value: "convenience_store" },
        { text: "Courthouse", value: "courthouse" },
        { text: "Dentist", value: "dentist" },
        { text: "Department Store", value: "department_store" },
        { text: "Doctor", value: "doctor" },
        { text: "Drugstore", value: "drugstore" },
        { text: "Electrician", value: "electrician" },
        { text: "Electronics Store", value: "electronics_store" },
        { text: "Embassy", value: "embassy" },
        { text: "Fire Station", value: "fire_station" },
        { text: "Florist", value: "florist" },
        { text: "Funeral Home", value: "funeral_home" },
        { text: "Furniture Store", value: "furniture_store" },
        { text: "Gas Station", value: "gas_station" },
        { text: "Gym", value: "gym" },
        { text: "Hair Care", value: "hair_care" },
        { text: "Hardware Store", value: "hardware_store" },
        { text: "Hindu Temple", value: "hindu_temple" },
        { text: "Home Goods Store", value: "home_goods_store" },
        { text: "Hospital", value: "hospital" },
        { text: "Insurance Agency", value: "insurance_agency" },
        { text: "Jewelry Store", value: "jewelry_store" },
        { text: "Laundry", value: "laundry" },
        { text: "Lawyer", value: "lawyer" },
        { text: "Library", value: "library" },
        { text: "Light Rail Station", value: "light_rail_station" },
        { text: "Liquor Store", value: "liquor_store" },
        { text: "Local Government Office", value: "local_government_office" },
        { text: "Locksmith", value: "locksmith" },
        { text: "Lodging", value: "lodging" },
        { text: "Meal Delivery", value: "meal_delivery" },
        { text: "Meal Takeaway", value: "meal_takeaway" },
        { text: "Mosque", value: "mosque" },
        { text: "Movie Rental", value: "movie_rental" },
        { text: "Movie Theater", value: "movie_theater" },
        { text: "Moving Company", value: "moving_company" },
        { text: "Museum", value: "museum" },
        { text: "Night Club", value: "night_club" },
        { text: "Painter", value: "painter" },
        { text: "Park", value: "park" },
        { text: "Parking", value: "parking" },
        { text: "Pet Store", value: "pet_store" },
        { text: "Pharmacy", value: "pharmacy" },
        { text: "Physiotherapist", value: "physiotherapist" },
        { text: "Plumber", value: "plumber" },
        { text: "Police", value: "police" },
        { text: "Post Office", value: "post_office" },
        { text: "Primary School", value: "primary_school" },
        { text: "Real Estate Agency", value: "real_estate_agency" },
        { text: "Restaurant", value: "restaurant" },
        { text: "Roofing Contractor", value: "roofing_contractor" },
        { text: "RV Park", value: "rv_park" },
        { text: "School", value: "school" },
        { text: "Secondary School", value: "secondary_school" },
        { text: "Shoe Store", value: "shoe_store" },
        { text: "Shopping Mall", value: "shopping_mall" },
        { text: "Spa", value: "spa" },
        { text: "Stadium", value: "stadium" },
        { text: "Storage", value: "storage" },
        { text: "Store", value: "store" },
        { text: "Subway Station", value: "subway_station" },
        { text: "Supermarket", value: "supermarket" },
        { text: "Synagogue", value: "synagogue" },
        { text: "Taxi Stand", value: "taxi_stand" },
        { text: "Tourist Attraction", value: "tourist_attraction" },
        { text: "Train Station", value: "train_station" },
        { text: "Transit Station", value: "transit_station" },
        { text: "Travel Agency", value: "travel_agency" },
        { text: "University", value: "university" },
        { text: "Veterinary Care", value: "veterinary_care" },
        { text: "Zoo", value: "zoo" },
      ],
    };
  },
  methods: {
    placeTypeSelected: function () {
      const places = new window.google.maps.places.PlacesService(this.map);
      const infoWindow = new window.google.maps.InfoWindow({
        content: this.$refs.infoContent,
      });

      const turf = window.turf;
      let intersection;
      let bbox;
      let markers = [];

      if (this.area.type == "Polygon") {
        intersection = turf.polygon(this.area.coordinates);
        bbox = turf.bbox(intersection);
      }
      if (this.area.type == "MultiPolygon") {
        intersection = turf.multiPolygon(this.area.coordinates);
        bbox = turf.bbox(intersection);
      }
      const sw = { lat: bbox[1], lng: bbox[0] };
      const ne = { lat: bbox[3], lng: bbox[2] };

      const search = {
        bounds: new window.google.maps.LatLngBounds(sw, ne),
        types: [this.selected],
      };
      places.nearbySearch(search, (results, status) => {
        if (
          status === window.google.maps.places.PlacesServiceStatus.OK &&
          results
        ) {
          const clearResults = this.$refs.results;

          while (clearResults.childNodes[0]) {
            clearResults.removeChild(results.childNodes[0]);
          }

          for (let i = 0; i < markers.length; i++) {
            if (markers[i]) {
              markers[i].setMap(null);
            }
          }
          markers = [];
          let filteredResults = [];
          results.forEach((result) => {
            let resultLat = result.geometry.location.lat();
            let resultLng = result.geometry.location.lng();
            let location = turf.point([resultLng, resultLat]);
            console.log(result);
            let intersectionAsLines = turf.polygonToLine(intersection);
            let locationDistanceFromIntersection = turf.nearestPointOnLine(
              intersectionAsLines,
              location,
              {
                units: "degrees",
              }
            ).properties.dist;
            console.log(locationDistanceFromIntersection);
            console.log(turf.booleanPointInPolygon(location, intersection));
            if (
              locationDistanceFromIntersection < 0.001 ||
              turf.booleanPointInPolygon(location, intersection)
            ) {
              filteredResults.push(result);
            }
          });
          console.log(results.length);
          console.log(filteredResults.length);
          for (let i = 0; i < filteredResults.length; i++) {
            // Use marker animation to drop the icons incrementally on the map.
            markers[i] = new window.google.maps.Marker({
              position: filteredResults[i].geometry.location,
              animation: window.google.maps.Animation.DROP,
            });
            // If the user clicks a marker, show the details in an info window.
            markers[i].placeResult = filteredResults[i];
            window.google.maps.event.addListener(
              markers[i],
              "click",
              function () {
                const marker = markers[i];
                places.getDetails(
                  { placeId: marker.placeResult.place_id },
                  (place, status) => {
                    if (
                      status !==
                      window.google.maps.places.PlacesServiceStatus.OK
                    ) {
                      return;
                    }
                    infoWindow.open(this.map, marker);
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
                      this.$refs.websiteURL.textContent = place.website;
                    } else {
                      this.$refs.iwWebsiteRow.style.display = "none";
                    }
                  }
                );
              }.bind(this)
            );

            setTimeout(
              function () {
                markers[i].setMap(this.map);
              }.bind(this),
              i * 100
            );
            const saveResults = this.$refs.results;
            const tr = document.createElement("tr");
            tr.style.backgroundColor = i % 2 === 0 ? "#F0F0F0" : "#FFFFFF";

            tr.onclick = function () {
              window.google.maps.event.trigger(markers[i], "click");
            };
            const nameTd = document.createElement("td");
            const name = document.createTextNode(filteredResults[i].name);
            nameTd.appendChild(name);
            tr.appendChild(nameTd);
            saveResults.appendChild(tr);
          }
        }
      });
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

  updated() {
    if (!this.missingArea) {
      this.missingArea = false;
      this.map = new window.google.maps.Map(this.$refs.map, {
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
      this.map.data.addGeoJson(geoJson);
    }
  },
};
</script>

<style >
#map {
  height: 100vh;
}
</style>