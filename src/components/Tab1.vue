<template>
  <div>
    <textarea
      class="textarea"
      id="chat"
      ref="log"
      cols="100"
      rows="20"
      readonly
    ></textarea
    ><br />
    <input id="message" ref="input" type="text" @keyup.enter="submit" /><input
      ref="submit"
      type="button"
      value="Send"
      @click="submit"
    />
    <br />
  </div>
</template>

<script>
export default {
  name: "Tab1",
  props: {
    socketRef: {
      type: WebSocket,
      required: false,
    },
    username: {
      type: String,
      required: true,
    },
  },
  methods: {
    submit: function () {
      const message = this.$refs.input.value;
      this.socketRef.send(
        JSON.stringify({
          message: message,
          user: this.username,
        })
      );
      this.$refs.input.value = "";
    },
  },
  mounted() {
    this.$refs.input.focus();
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
</style> 