<template>
  <span>Your rooms:</span><br /><br /><button @click="createNewRoom">
    New room</button
  ><br /><br />
  <div id="array-rendering">
    <span v-for="notification in notifications" :key="notification.room">
      <div
        v-if="notification.read"
        class="read-notification"
        v-bind:class="{ room: notification.current_room }"
      >
        <ChatNotification :notification="notification" :socketRef="socketRef" />
      </div>
      <div v-else class="unread-notification">
        <ChatNotification :notification="notification" :socketRef="socketRef" />
      </div>
      <br />
    </span>
  </div>
</template>
<script>
import ChatNotification from "./ChatNotification.vue";
export default {
  name: "ChatHistory",
  components: {
    ChatNotification,
  },
  props: {
    socketRef: {
      type: WebSocket,
      required: false,
    },
    notifications: {
      type: Array,
      required: true,
    },
  },
  methods: {
    createNewRoom: function () {
      window.location.href = window.location.href.split("?")[0];
    },
  },
};
</script>
<style scoped>
.unread-notification {
  background-color: rgb(255, 187, 187);
}
.room {
  background-color: rgb(187, 233, 255);
}
#array-rendering {
  height: 30vh;
  overflow-y: auto;
  overflow-x: visible;
}
</style>
