<template>
  <span>Your rooms:</span><br /><br /><button @click="createNewRoom">
    New room
  </button>
  <ul id="array-rendering">
    <li v-for="notification in notifications" :key="notification.room">
      <div v-if="notification.read" class="read-notification">
        <ChatNotification :notification="notification" :socketRef="socketRef" />
      </div>
      <div v-else class="unread-notification">
        <ChatNotification :notification="notification" :socketRef="socketRef" />
      </div>
      <br />
    </li>
  </ul>
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
  background-color: #5dbeff;
}
#array-rendering {
  list-style-type: none;
  height: 30vh;
  overflow-y: auto;
  overflow-x: visible;
}
</style>
