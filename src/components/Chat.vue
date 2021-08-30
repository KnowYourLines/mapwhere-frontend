<template>
  <div v-if="userAllowed">
    <div class="column-right">
      <br />
      <ChatMembers
        :roomMembers="roomMembers"
        :privateRoom="privateRoom"
        :joinRequests="joinRequests"
        :socketRef="socketRef"
      />
    </div>

    <div class="column-center">
      Room name:
      <input
        type="text"
        autocomplete="on"
        :value="roomName"
        @change="$emit('update:roomName', $event.target.value)"
        @keyup.enter="updateRoomName"
        @focus="$event.target.select()"
      /><br />
      Speaking as:
      <input
        type="text"
        autocomplete="on"
        :value="username"
        @change="$emit('update:username', $event.target.value)"
        @keyup.enter="updateDisplayName"
        @focus="$event.target.select()"
      />
      <br /><br />
      <button
        class="tab-button"
        ref="tab1"
        v-bind:class="{ active: currentTabComponent === 'Tab1' }"
        @click="chatSelected"
      >
        Chat
      </button>
      <button
        class="tab-button"
        ref="tab2"
        v-bind:class="{ active: currentTabComponent === 'Tab2' }"
        @click="findSelected"
      >
        Find
      </button>
      <button
        class="tab-button"
        ref="tab3"
        v-bind:class="{ active: currentTabComponent === 'Tab3' }"
        @click="areaSelected"
      >
        Area
      </button>
      <button
        class="tab-button"
        v-bind:class="{ active: currentTabComponent === 'Tab4' }"
        @click="currentTabComponent = 'Tab4'"
      >
        Vote
      </button>
      <component
        ref="component"
        :is="currentTabComponent"
        :socketRef="socketRef"
        :username="username"
        :locationBubble="locationBubble"
        :isochroneServiceRegion="isochroneRegion"
        :area="area"
        :usersMissingLocations="usersMissingLocations"
        :user="user"
      ></component>
      <br />
    </div>
    <div class="column-left">
      <br />
      <ChatHistory :notifications="notifications" :socketRef="socketRef" />
    </div>
  </div>
  <div class="column-center" v-else>
    User not allowed in private room. Access requested.
  </div>
</template>

<script>
import ChatHistory from "./ChatHistory.vue";
import ChatMembers from "./ChatMembers.vue";
import Tab1 from "./Tab1.vue";
import Tab2 from "./Tab2.vue";
import Tab3 from "./Tab3.vue";
import Tab4 from "./Tab4.vue";
export default {
  name: "Chat",
  components: {
    ChatHistory,
    ChatMembers,
    Tab1,
    Tab2,
    Tab3,
    Tab4,
  },
  data() {
    return {
      currentTabComponent: "Tab2",
    };
  },
  props: {
    socketRef: {
      type: WebSocket,
      required: false,
    },
    user: {
      type: Object,
      required: true,
    },
    joinRequests: {
      type: Array,
      required: true,
    },
    notifications: {
      type: Array,
      required: true,
    },
    roomMembers: {
      type: Array,
      required: true,
    },
    username: {
      type: String,
      required: true,
    },
    roomName: {
      type: String,
      required: true,
    },
    privateRoom: {
      type: Boolean,
      required: true,
    },
    userAllowed: {
      type: Boolean,
      required: true,
    },
    locationBubble: {
      type: Object,
      required: true,
    },
    area: {
      type: Object,
      required: true,
    },
    usersMissingLocations: {
      type: Array,
      required: true,
    },
    isochroneRegion: {
      type: String,
      required: false,
    },
  },
  methods: {
    chatSelected: function () {
      if (this.currentTabComponent != "Tab1") {
        this.socketRef.send(JSON.stringify({ command: "fetch_messages" }));
        this.currentTabComponent = "Tab1";
        this.$refs.tab1.style.backgroundColor = null;
      }
    },
    findSelected: function () {
      this.socketRef.send(JSON.stringify({ command: "fetch_location_bubble" }));
      this.currentTabComponent = "Tab2";
    },
    areaSelected: function () {
      this.socketRef.send(JSON.stringify({ command: "fetch_intersection" }));
      this.currentTabComponent = "Tab3";
      this.$refs.tab3.style.backgroundColor = null;
    },
    updateDisplayName: function () {
      this.socketRef.send(
        JSON.stringify({
          command: "update_display_name",
          name: this.username,
        })
      );
      if (this.$refs.component.$refs.input) {
        this.$refs.component.$refs.input.focus();
      }
    },
    updateRoomName: function () {
      this.socketRef.send(
        JSON.stringify({
          command: "update_room_name",
          name: this.roomName,
        })
      );
      if (this.$refs.component.$refs.input) {
        this.$refs.component.$refs.input.focus();
      }
    },
  },
  beforeUpdate() {
    if (this.currentTabComponent !== "Tab2") {
      this.$refs.tab2.style.backgroundColor = null;
      this.usersMissingLocations.forEach((user) => {
        if (user.username == this.user.uid) {
          this.$refs.tab2.style.backgroundColor = "#5dbeff";
        }
      });
    } else {
      this.$refs.tab2.style.backgroundColor = null;
    }
  },
};
</script>
<style scoped>
@media (orientation: landscape) {
  .column-left {
    float: left;
    width: 33.333%;
  }
  .column-right {
    float: right;
    width: 33.333%;
  }
  .column-center {
    display: inline-block;
    width: 33.333%;
  }
}
@media (orientation: portrait) {
  .column-left {
    width: 100%;
    background-color: rgb(227, 246, 255);
  }
  .column-right {
    width: 100%;
    background-color: rgb(227, 246, 255);
  }
  .column-center {
    width: 100%;
  }
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