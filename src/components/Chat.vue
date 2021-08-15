<template>
  <div v-if="userAllowed">
    <div class="column-left">
      <ChatHistory :notifications="notifications" :socketRef="socketRef" />
    </div>
    <div class="column-center">
      Room name:
      <input
        type="text"
        autocomplete="on"
        :value="roomName"
        @input="$emit('update:roomName', $event.target.value)"
        @keyup.enter="updateRoomName"
      /><br />
      Speaking as:
      <input
        type="text"
        autocomplete="on"
        :value="username"
        @input="$emit('update:username', $event.target.value)"
        @keyup.enter="updateDisplayName"
      />
      <br /><br />
      <button ref="tab1" @click="chatSelected">Chat</button>
      <button @click="findSelected">Find</button>
      <button @click="currentTabComponent = 'Tab3'">tab 3</button>
      <component
        ref="component"
        :is="currentTabComponent"
        :socketRef="socketRef"
        :username="username"
      ></component>
    </div>
    <div class="column-right">
      <ChatMembers
        :roomMembers="roomMembers"
        :privateRoom="privateRoom"
        :joinRequests="joinRequests"
        :socketRef="socketRef"
      />
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
export default {
  name: "Chat",
  components: {
    ChatHistory,
    ChatMembers,
    Tab1,
    Tab2,
    Tab3,
  },
  data() {
    return {
      currentTabComponent: "Tab1",
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
      this.currentTabComponent = "Tab2";
    },
    updateDisplayName: function () {
      this.socketRef.send(
        JSON.stringify({
          command: "update_display_name",
          name: this.username,
        })
      );
      this.socketRef.send(JSON.stringify({ command: "fetch_display_name" }));
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
};
</script>
<style >
#chat {
  max-width: 100%;
}
#message {
  width: 100%;
}
#array-rendering {
  list-style-type: none;
}
</style> 