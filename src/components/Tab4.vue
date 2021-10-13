<template>
  <div>
    <div v-if="places.length > 0" ref="listing" id="listing">
      <table class="listing-table">
        <tbody>
          <tr class="places" v-for="(place, index) in places" :key="index">
            <td>
              <img :src="place.icon" /><br /><a
                :href="place.url"
                target="_blank"
                rel="noopener noreferrer"
                >{{ place.name }}</a
              ><br />{{ place.vicinity
              }}<span v-if="place.formatted_phone_number">
                <br />{{ place.formatted_phone_number }} </span
              ><br /><br />{{ place.travel_time.text }} away
            </td>
            <td>
              <span v-if="place.website">
                <br /><b
                  ><a
                    :href="place.website"
                    target="_blank"
                    rel="noopener noreferrer"
                    >Go to website</a
                  ></b
                >
              </span>
              <span v-if="place.rating">
                <br />Rating:
                <span v-for="(number, index) in 5" :key="index"
                  ><span v-if="place.rating < index + 0.5">&#10025;</span>
                  <span v-else>&#10029;</span></span
                ></span
              ><span v-if="place.price_level">
                <br />Price:
                <span v-if="place.price_level == 0">Free</span>
                <span v-else>
                  <span v-for="level in place.price_level" :key="level"
                    ><span>&#128178;</span>
                  </span></span
                >
              </span>

              <span v-if="place.opening_hours">
                <span v-if="place.opening_hours.open_now"
                  ><br /><img src="@/assets/icons8-open-sign-50.png" /></span
                ><br /><button
                  v-if="!viewOpenHours[index]"
                  @click="viewOpeningHours(index)"
                >
                  View opening hours
                </button>
                <span v-else>
                  <button @click="closeOpeningHours(index)">
                    Close opening hours</button
                  ><br /><br />
                  <span
                    v-for="hours in place.opening_hours.weekday_text"
                    :key="hours"
                  >
                    {{ hours }}<br /><br />
                  </span>
                </span>
              </span>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-else><br />No places saved.</div>
  </div>
</template>

<script>
export default {
  name: "Tab4",
  props: {
    socketRef: {
      type: WebSocket,
      required: false,
    },
    places: {
      type: Array,
      required: true,
    },
  },
  data() {
    return {
      viewOpenHours: this.places.map(() => false),
    };
  },
  methods: {
    viewOpeningHours: function (index) {
      this.viewOpenHours[index] = true;
    },
    closeOpeningHours: function (index) {
      this.viewOpenHours[index] = false;
    },
  },
};
</script>

<style scoped>
#listing {
  height: 80vh;
  overflow-y: auto;
  overflow-x: visible;
}
.listing-table {
  display: table;
  width: 100%;
}
.places:nth-child(odd) {
  background-color: rgb(227, 246, 255);
}
.places:hover {
  background: #e0e0e0;
}
.places.active {
  background: #e0e0e0;
}
</style>