<template>
  <SignIn
    @new-user="newUser"
    @socket-created="socketCreated"
    @new-room-members="newRoomMembers"
    @new-notifications="newNotifications"
    @new-join-requests="newJoinRequests"
    @new-allowed-status="newAllowedStatus"
    @new-room-name="newRoomName"
    @clear-chat="clearChat"
    @new-username="newUsername"
    @new-message="newMessage"
    @fetching-message="fetchingMessage"
    @new-privacy="newPrivacy"
    @found-location-bubble="foundLocationBubble"
    @isochrone-regions="findIsochroneRegion"
    @new-area="newArea"
    @users-missing-locations="newUsersMissingLocations"
    @new-isochrones="newIsochrones"
    @highlight-area="highlightArea"
    @highlight-chat="highlightChat"
    @highlight-vote="highlightVote"
    @area-query="areaQueryFound"
    @new-places="newPlacesFound"
    @new-area-query-results="newAreaQueryResults"
    @next-page-places-token="newNextPagePlacesToken"
    @next-page-places="nextPagePlacesResults"
  />
  <br /><br />
  <Toggle v-if="userAllowed" v-model="privateRoom" @change="updatePrivacy">
    <template v-slot:label="{ checked, classList }">
      <span :class="classList.label">{{ checked ? "Private" : "Public" }}</span>
    </template>
  </Toggle>
  <br /><br />
  <Chat
    ref="chat"
    :socketRef="socket"
    :user="user"
    :roomMembers="roomMembers"
    :joinRequests="joinRequests"
    :notifications="notifications"
    :privateRoom="privateRoom"
    :userAllowed="userAllowed"
    :locationBubble="locationBubble"
    :isochroneRegion="isochroneRegion"
    :area="area"
    :usersMissingLocations="usersMissingLocations"
    :areaQuery="areaQuery"
    :areaQueryResults="areaQueryResults"
    :nextPagePlacesToken="nextPagePlacesToken"
    :nextPagePlaces="nextPagePlaces"
    v-model:username.lazy.trim="username"
    v-model:roomName.lazy.trim="roomName"
    @new-join-requests="newJoinRequests"
  />
</template>

<script>
import Toggle from "@vueform/toggle";
import Chat from "./components/Chat.vue";
import SignIn from "./components/SignIn.vue";

export default {
  name: "App",
  components: {
    Toggle,
    Chat,
    SignIn,
  },
  data() {
    return {
      socket: null,
      user: {},
      joinRequests: [],
      notifications: [],
      roomMembers: [],
      username: "",
      roomName: "",
      privateRoom: false,
      userAllowed: true,
      locationBubble: {},
      isochroneRegion: "",
      area: {},
      usersMissingLocations: [],
      areaQuery: "",
      places: [],
      areaQueryResults: [],
      nextPagePlacesToken: "",
      nextPagePlaces: [],
    };
  },
  methods: {
    nextPagePlacesResults: function (places, tokenUsed) {
      if (tokenUsed == this.nextPagePlacesToken) {
        this.nextPagePlaces = places;
      }
    },
    newNextPagePlacesToken: function (token) {
      this.nextPagePlacesToken = token;
    },
    newAreaQueryResults: function (results) {
      this.areaQueryResults = results;
    },
    newPlacesFound: function (newPlaces) {
      this.places = newPlaces;
      if (this.$refs.chat.$refs.component) {
        if (this.$refs.chat.currentTabComponent != "Tab4") {
          this.$refs.chat.$refs.tab4.style.backgroundColor = "#5dbeff";
        }
      }
    },
    highlightVote: function () {
      if (this.$refs.chat.$refs.component) {
        if (this.$refs.chat.currentTabComponent != "Tab4") {
          this.$refs.chat.$refs.tab4.style.backgroundColor = "#5dbeff";
        }
      }
    },
    areaQueryFound: function (query) {
      this.areaQuery = query;
    },
    newIsochrones: function (isochrones) {
      const turf = window.turf;
      let intersection = isochrones[0];
      isochrones.slice(1).forEach((isochrone) => {
        if (intersection) {
          let isochroneMultiPolygon = turf.multiPolygon(
            isochrone.geometry.coordinates
          );
          if (intersection.geometry.type == "Polygon") {
            intersection = turf.intersect(
              turf.polygon(intersection.geometry.coordinates),
              isochroneMultiPolygon
            );
          }
          if (intersection.geometry.type == "MultiPolygon") {
            intersection = turf.intersect(
              turf.multiPolygon(intersection.geometry.coordinates),
              isochroneMultiPolygon
            );
          }
        }
      });
      if (intersection) {
        let center = turf.centerOfMass(intersection);
        const newArea = {
          centroid_lat: center.geometry.coordinates[1],
          centroid_lng: center.geometry.coordinates[0],
          type: intersection.geometry.type,
          coordinates: intersection.geometry.coordinates,
        };
        this.socket.send(
          JSON.stringify({ command: "update_intersection", ...newArea })
        );
      } else {
        this.socket.send(JSON.stringify({ command: "delete_intersection" }));
      }
    },
    newArea: function (area) {
      this.area = area;
      if (this.$refs.chat.$refs.component) {
        if (
          !this.$refs.chat.$refs.component.$refs.map &&
          !this.$refs.chat.$refs.component.$refs.noArea
        ) {
          this.$refs.chat.$refs.tab3.style.backgroundColor = "#5dbeff";
        }
      }
    },
    highlightArea: function () {
      if (this.$refs.chat.$refs.component) {
        if (
          !this.$refs.chat.$refs.component.$refs.map &&
          !this.$refs.chat.$refs.component.$refs.noArea
        ) {
          this.$refs.chat.$refs.tab3.style.backgroundColor = "#5dbeff";
        }
      }
    },
    newUsersMissingLocations: function (users) {
      this.usersMissingLocations = users;
    },
    updatePrivacy: function () {
      if (!this.privateRoom) {
        this.joinRequests = [];
        this.socket.send(JSON.stringify({ command: "approve_all_users" }));
      }
      this.socket.send(
        JSON.stringify({
          command: "update_privacy",
          privacy: this.privateRoom,
        })
      );
      if (this.$refs.chat.$refs.component) {
        if (this.$refs.chat.$refs.component.$refs.input) {
          this.$refs.chat.$refs.component.$refs.input.focus();
        }
      }
    },
    socketCreated: function (socket) {
      this.socket = socket;
    },
    newUser: function (user) {
      this.user = user;
    },
    newRoomMembers: function (members) {
      this.roomMembers = members;
    },
    newNotifications: function (notifications) {
      this.notifications = notifications;
    },
    newJoinRequests: function (requests) {
      this.joinRequests = requests;
    },
    newAllowedStatus: function (status) {
      this.userAllowed = status;
    },
    newRoomName: function (name) {
      this.roomName = name;
    },
    newUsername: function (username) {
      this.username = username;
    },
    newPrivacy: function (privacy) {
      this.privateRoom = privacy;
    },
    newMessage: function (message) {
      if (this.$refs.chat.$refs.component) {
        if (this.$refs.chat.$refs.component.$refs.log) {
          this.$refs.chat.$refs.component.$refs.log.value += message;
        } else {
          this.$refs.chat.$refs.tab1.style.backgroundColor = "#5dbeff";
        }
      }
    },
    highlightChat: function () {
      if (this.$refs.chat.$refs.component) {
        if (!this.$refs.chat.$refs.component.$refs.log) {
          this.$refs.chat.$refs.tab1.style.backgroundColor = "#5dbeff";
        }
      }
    },
    foundLocationBubble: function (locationBubble) {
      this.locationBubble = locationBubble;
      this.isochroneRegion = locationBubble.region;
    },
    findIsochroneRegion: function (regionIsochrones, locationLng, locationLat) {
      const turf = window.turf;
      const location = turf.point([locationLng, locationLat]);
      const possibleRegions = [];
      regionIsochrones.forEach((regionIsochrone) => {
        let isochroneMultiPolygon = turf.multiPolygon(
          regionIsochrone.isochrone.geometry.coordinates
        );
        let isochroneAsLines = turf.polygonToLine(isochroneMultiPolygon);
        let locationDistanceFromIsochrone = turf.nearestPointOnLine(
          isochroneAsLines,
          location,
          {
            units: "degrees",
          }
        ).properties.dist;
        let isochroneArea = turf.area(isochroneMultiPolygon);
        if (locationDistanceFromIsochrone < 0.001) {
          possibleRegions.push({
            area: isochroneArea,
            regionName: regionIsochrone.region,
            travelMode: regionIsochrone.travel_mode,
          });
        }
      });
      if (possibleRegions.length > 0) {
        let userRegion = possibleRegions[0];
        possibleRegions.slice(1).forEach((region) => {
          if (
            userRegion.area < region.area &&
            userRegion.travelMode == "walk" &&
            region.travelMode == "transit" &&
            region.regionName != "central_america"
          ) {
            userRegion = region;
          }
        });
        this.isochroneRegion = userRegion.regionName;
      } else {
        this.isochroneRegion = "";
      }
    },
    fetchingMessage: function (message) {
      if (this.$refs.chat.$refs.component) {
        if (this.$refs.chat.$refs.component.$refs.log) {
          this.$refs.chat.$refs.component.$refs.log.value += message;
        }
      }
    },
    clearChat: function () {
      if (this.$refs.chat.$refs.component) {
        if (this.$refs.chat.$refs.component.$refs.log) {
          this.$refs.chat.$refs.component.$refs.log.value = "";
        }
      }
    },
  },
};
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
.toggle-container {
  display: inline-block;
}
.toggle-container:focus {
  outline: none;
  box-shadow: 0 0 0 var(--toggle-ring-width, 3px)
    var(--toggle-ring-color, rgba(16, 185, 129, 0.18823529411764706));
}
.toggle {
  display: flex;
  width: var(--toggle-width, 5rem);
  height: var(--toggle-height, 1.25rem);
  border-radius: 999px;
  position: relative;
  cursor: pointer;
  transition: all 0.3s;
  align-items: center;
  box-sizing: content-box;
  border: var(--toggle-border, 0.125rem) solid;
  font-size: var(--toggle-font-size, 1rem);
  line-height: 1;
}
.toggle-on {
  background: var(--toggle-bg-on, #10b981);
  border-color: var(--toggle-border-on, #10b981);
  justify-content: flex-start;
  color: var(--toggle-text-on, #fff);
}
.toggle-off {
  background: var(--toggle-bg-off, #e5e7eb);
  border-color: var(--toggle-border-off, #e5e7eb);
  justify-content: flex-end;
  color: var(--toggle-text-off, #374151);
}
.toggle-on-disabled {
  background: var(--toggle-bg-on-disabled, #d1d5db);
  border-color: var(--toggle-border-on-disabled, #d1d5db);
  justify-content: flex-start;
  color: var(--toggle-text-on-disabled, #9ca3af);
  cursor: not-allowed;
}
.toggle-off-disabled {
  background: var(--toggle-bg-off-disabled, #e5e7eb);
  border-color: var(--toggle-border-off-disabled, #e5e7eb);
  justify-content: flex-end;
  color: var(--toggle-text-off-disabled, #9ca3af);
  cursor: not-allowed;
}
.toggle-handle {
  display: inline-block;
  background: var(--toggle-handle-enabled, #fff);
  width: 20px;
  height: 20px;
  top: 0;
  border-radius: 50%;
  position: absolute;
  transition-property: all;
  transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
  transition-duration: var(--toggle-duration, 0.15s);
}
.toggle-handle-on {
  left: 100%;
  transform: translateX(-100%);
}
.toggle-handle-off {
  left: 0;
}
.toggle-handle-on-disabled {
  left: 100%;
  transform: translateX(-100%);
  background: var(--toggle-handle-disabled, #f3f4f6);
}
.toggle-handle-off-disabled {
  left: 0;
  background: var(--toggle-handle-disabled, #f3f4f6);
}
.toggle-label {
  text-align: center;
  width: calc(var(--toggle-width, 5rem) - var(--toggle-height, 1.25rem));
  box-sizing: border-box;
  white-space: nowrap;
  -webkit-user-select: none;
  -moz-user-select: none;
  -ms-user-select: none;
  user-select: none;
}
</style>
