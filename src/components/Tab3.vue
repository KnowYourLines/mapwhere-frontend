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
    <div v-if="!missingArea" id="v-model-select-dynamic" class="demo">
      <br />
      <select v-model="selected">
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
    <div v-if="!missingArea" id="map" ref="map"></div>
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
        { text: "Lawyer", value: "Lawyer" },
        { text: "Library", value: "library" },
        { text: "Light Rail Station", value: "light_rail_station" },
        { text: "Liquor Store", value: "liquor_store" },
        { text: "Local Government Office", value: "local_government_office" },
        { text: "Locksmith", value: "locksmith" },
        { text: "Lodging", value: "lodging" },
        { text: "Meal_delivery", value: "meal_delivery" },
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
    }
  },
};
</script>

<style >
#map {
  height: 100vh;
}
</style>