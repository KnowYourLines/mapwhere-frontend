<template>
  <div>
    <div class="column">
      <div v-if="showSignIn">
        <section ref="firebaseui"></section>
        <div v-if="shareable">
          <button @click="share">Share</button>
        </div>
      </div>
      <div v-else>
        <div v-if="shareable">
          <div class="column-left">
            <button @click="signOut">Sign Out</button>
          </div>
          <div class="column-right">
            <button @click="share">Share</button>
          </div>
        </div>
        <div v-else>
          <div>
            <button @click="signOut">Sign Out</button>
          </div>
        </div>
      </div>
    </div>
    <br />
  </div>
</template>

<script>
import { v4 as uuidv4 } from "uuid";
import firebase from "firebase";
import * as firebaseui from "firebaseui";
import "firebaseui/dist/firebaseui.css";
export default {
  name: "SignIn",
  emits: [
    "new-user",
    "socket-created",
    "new-room-members",
    "new-notifications",
    "new-join-requests",
    "new-allowed-status",
    "new-room-name",
    "clear-chat",
    "new-username",
    "new-message",
    "new-privacy",
    "fetching-message",
    "found-location-bubble",
    "isochrone-regions",
    "new-area",
    "users-missing-locations",
    "new-isochrones",
    "highlight-chat",
    "highlight-area",
    "highlight-vote",
    "area-query",
    "new-places",
    "new-area-query-results",
    "next-page-places-token",
    "next-page-places",
  ],
  data() {
    return {
      token: null,
      showSignIn: true,
      shareable: null,
    };
  },
  methods: {
    signOut: function () {
      firebase
        .auth()
        .signOut()
        .catch((err) => {
          console.log(err);
        });
    },
    share: function () {
      const shareData = {
        url: window.location.href,
      };
      navigator.share(shareData);
    },
  },
  mounted() {
    this.shareable = typeof navigator.share === "function";
    const urlParams = new URLSearchParams(window.location.search);
    let room = urlParams.get("room");
    if (!room) {
      room = uuidv4();
      let url = new URL(window.location.href);
      url.searchParams.set("room", room);
      window.location.href = url;
    }
    const firebaseConfig = {
      apiKey: process.env.VUE_APP_FIREBASE_API_KEY,
      authDomain: process.env.VUE_APP_FIREBASE_AUTH_DOMAIN,
      projectId: process.env.VUE_APP_FIREBASE_PROJECT_ID,
      storageBucket: process.env.VUE_APP_FIREBASE_STORAGE_BUCKET,
      messagingSenderId: process.env.VUE_APP_FIREBASE_MESSAGING_SENDER_ID,
      appId: process.env.VUE_APP_FIREBASE_APP_ID,
      measurementId: process.env.VUE_APP_FIREBASE_MEASUREMENT_ID,
    };
    firebase.initializeApp(firebaseConfig);
    this.ui = firebaseui.auth.AuthUI.getInstance();
    if (!this.ui) {
      this.ui = new firebaseui.auth.AuthUI(firebase.auth());
    }
    firebase.auth().onAuthStateChanged((user) => {
      console.log(user);
      if (user) {
        this.user = user;
        this.$emit("new-user", this.user);
        user.getIdToken().then((token) => {
          this.token = token;
          this.showSignIn = this.user.isAnonymous;
          if (this.showSignIn) {
            this.$nextTick(() => {
              this.ui.start(this.$refs.firebaseui, this.uiConfig);
            });
          }
          const backendUrl = new URL(process.env.VUE_APP_BACKEND_URL);
          const ws_scheme = backendUrl.protocol == "https:" ? "wss" : "ws";
          const path =
            ws_scheme +
            "://" +
            backendUrl.hostname +
            ":" +
            backendUrl.port +
            "/ws/chat/" +
            room +
            "/?token=" +
            this.token;
          if (this.socketRef) {
            this.socketRef.close();
          }
          this.socketRef = new WebSocket(path);
          this.$emit("socket-created", this.socketRef);
          this.socketRef.onopen = () => {
            console.log("WebSocket open");
            this.socketRef.send(JSON.stringify({ command: "join_room" }));
            this.socketRef.send(JSON.stringify({ command: "fetch_messages" }));
            this.socketRef.send(JSON.stringify({ command: "fetch_room_name" }));
            this.socketRef.send(JSON.stringify({ command: "fetch_privacy" }));
            this.socketRef.send(
              JSON.stringify({ command: "fetch_user_notifications" })
            );
            this.socketRef.send(JSON.stringify({ command: "fetch_members" }));
            this.socketRef.send(
              JSON.stringify({ command: "fetch_display_name" })
            );
            this.socketRef.send(
              JSON.stringify({
                command: "fetch_location_bubble",
              })
            );
            this.socketRef.send(
              JSON.stringify({
                command: "fetch_area_query",
              })
            );
          };
          this.socketRef.onmessage = (e) => {
            const data = JSON.parse(e.data);
            if ("members" in data) {
              this.roomMembers = JSON.parse(data.members);
              this.$emit("new-room-members", this.roomMembers);
            } else if ("refresh_members" in data) {
              this.socketRef.send(JSON.stringify({ command: "fetch_members" }));
            } else if ("notifications" in data) {
              this.notifications = JSON.parse(data.notifications);
              this.$emit("new-notifications", this.notifications);
            } else if ("requests" in data) {
              this.joinRequests = JSON.parse(data.requests);
              this.$emit("new-join-requests", this.joinRequests);
            } else if ("refresh_notifications" in data) {
              this.socketRef.send(
                JSON.stringify({ command: "fetch_user_notifications" })
              );
            } else if ("refresh_allowed_status" in data) {
              this.socketRef.send(
                JSON.stringify({
                  command: "fetch_allowed_status",
                })
              );
            } else if ("allowed" in data) {
              this.userAllowed = true;
              this.$emit("new-allowed-status", this.userAllowed);
            } else if ("not_allowed" in data) {
              this.userAllowed = false;
              this.$emit("new-allowed-status", this.userAllowed);
            } else if ("privacy" in data) {
              this.privateRoom = data.privacy;
              if (this.privateRoom) {
                this.socketRef.send(
                  JSON.stringify({ command: "fetch_join_requests" })
                );
              }
              this.$emit("new-privacy", this.privateRoom);
            } else if ("refresh_join_requests" in data) {
              this.socketRef.send(
                JSON.stringify({ command: "fetch_join_requests" })
              );
            } else if ("refresh_privacy" in data) {
              this.socketRef.send(JSON.stringify({ command: "fetch_privacy" }));
            } else if ("new_room_name" in data) {
              this.roomName = data.new_room_name;
              this.$emit("new-room-name", this.roomName);
            } else if ("refresh_room_name" in data) {
              this.socketRef.send(
                JSON.stringify({ command: "fetch_room_name" })
              );
            } else if ("refresh_chat" in data) {
              this.$emit("clear-chat");
              this.socketRef.send(
                JSON.stringify({ command: "fetch_messages" })
              );
            } else if ("new_display_name" in data) {
              this.username = data.new_display_name;
              this.$emit("new-username", this.username);
              if (
                this.user.providerData[0] &&
                (this.username === this.user.providerData[0].displayName ||
                  this.username === this.user.providerData[0].email ||
                  this.username === this.user.providerData[0].phoneNumber ||
                  this.username === this.user.providerData[0].uid)
              ) {
                this.username =
                  this.user.providerData[0].displayName ||
                  this.user.providerData[0].email ||
                  this.user.providerData[0].phoneNumber ||
                  this.user.providerData[0].uid;
                this.$emit("new-username", this.username);
                this.socketRef.send(
                  JSON.stringify({
                    command: "update_display_name",
                    name: this.username,
                  })
                );
              } else if (
                this.user.providerData[0] &&
                (this.username === this.user.displayName ||
                  this.username === this.user.email ||
                  this.username === this.user.phoneNumber ||
                  this.username === this.user.uid)
              ) {
                this.username =
                  this.user.providerData[0].displayName ||
                  this.user.displayName ||
                  this.user.providerData[0].email ||
                  this.user.email ||
                  this.user.providerData[0].phoneNumber ||
                  this.user.phoneNumber ||
                  this.user.providerData[0].uid ||
                  this.user.uid;
                this.$emit("new-username", this.username);
                this.socketRef.send(
                  JSON.stringify({
                    command: "update_display_name",
                    name: this.username,
                  })
                );
              } else if (
                this.username === this.user.displayName ||
                this.username === this.user.email ||
                this.username === this.user.phoneNumber ||
                this.username === this.user.uid
              ) {
                this.username =
                  this.user.displayName ||
                  this.user.email ||
                  this.user.phoneNumber ||
                  this.user.uid;
                this.$emit("new-username", this.username);
                this.socketRef.send(
                  JSON.stringify({
                    command: "update_display_name",
                    name: this.username,
                  })
                );
              }
            } else if ("fetching_message" in data) {
              this.$emit("fetching-message", data.fetching_message + "\n");
            } else if ("refresh_area" in data) {
              this.socketRef.send(
                JSON.stringify({ command: "fetch_intersection" })
              );
            } else if ("recalculate_intersection" in data) {
              this.socketRef.send(
                JSON.stringify({ command: "calculate_intersection" })
              );
            } else if ("area" in data) {
              this.$emit("new-area", data.area);
            } else if ("isochrones" in data) {
              this.$emit("new-isochrones", data.isochrones);
            } else if ("refresh_users_missing_locations" in data) {
              this.socketRef.send(
                JSON.stringify({ command: "fetch_users_missing_locations" })
              );
            } else if ("users_missing_locations" in data) {
              this.$emit(
                "users-missing-locations",
                data.users_missing_locations
              );
            } else if ("location_bubble" in data) {
              if (data.location_bubble) {
                this.$emit("found-location-bubble", data.location_bubble);
              }
            } else if ("region_isochrones" in data) {
              this.$emit(
                "isochrone-regions",
                data.region_isochrones,
                data.location_lng,
                data.location_lat
              );
            } else if ("highlight_chat" in data) {
              this.$emit("highlight-chat");
            } else if ("highlight_vote" in data) {
              this.$emit("highlight-vote");
            } else if ("highlight_area" in data) {
              this.$emit("highlight-area");
            } else if ("area_query" in data) {
              this.$emit("area-query", data.area_query);
            } else if ("refresh_area_query" in data) {
              this.socketRef.send(
                JSON.stringify({ command: "fetch_area_query" })
              );
            } else if ("refresh_places" in data) {
              this.socketRef.send(JSON.stringify({ command: "fetch_places" }));
            } else if ("region_not_found" in data) {
              alert("Location must be more specific!");
            } else if ("places" in data) {
              this.$emit("new-places", data.places);
            } else if ("area_query_results" in data) {
              this.$emit(
                "new-area-query-results",
                data.area_query_results,
                data.next_page_places_token
              );
            } else if ("next_page_place_results" in data) {
              this.$emit(
                "next-page-places",
                data.next_page_place_results,
                data.token_used,
                data.next_page_places_token
              );
            } else {
              this.$emit("new-message", data.message + "\n");
            }
          };
          this.socketRef.onerror = (e) => {
            console.log(e.message);
          };
          this.socketRef.onclose = () => {
            console.log("WebSocket closed");
          };
        });
      } else {
        firebase.auth().signInAnonymously();
      }
    });
    this.ui = firebaseui.auth.AuthUI.getInstance();
    this.uiConfig = {
      autoUpgradeAnonymousUsers: true,
      signInSuccessUrl: window.location.href,
      signInOptions: [
        firebase.auth.GoogleAuthProvider.PROVIDER_ID,
        firebase.auth.FacebookAuthProvider.PROVIDER_ID,
        firebase.auth.PhoneAuthProvider.PROVIDER_ID,
        {
          provider: firebase.auth.EmailAuthProvider.PROVIDER_ID,
          signInMethod:
            firebase.auth.EmailAuthProvider.EMAIL_LINK_SIGN_IN_METHOD,
        },
      ],
      callbacks: {
        // signInFailure callback must be provided to handle merge conflicts which
        // occur when an existing credential is linked to an anonymous user.
        signInFailure: function (error) {
          // For merge conflicts, the error.code will be
          // 'firebaseui/anonymous-upgrade-merge-conflict'.
          if (error.code != "firebaseui/anonymous-upgrade-merge-conflict") {
            return Promise.resolve();
          }
          // The credential the user tried to sign in with.
          var cred = error.credential;
          // Copy data from anonymous user to permanent user and delete anonymous
          // user.
          // ...
          // Finish sign-in after data is copied.
          return firebase.auth().signInWithCredential(cred);
        },
      },
    };
  },
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
@media (orientation: landscape) {
  .column {
    display: inline-block;
    width: 33.333%;
  }
  .column-left {
    float: left;
    width: 50%;
    padding-bottom: 1em;
  }
  .column-right {
    float: right;
    width: 50%;
    padding-bottom: 1em;
  }
}
@media (orientation: portrait) {
  .column {
    display: inline-block;
    width: 100%;
  }
  .column-left {
    float: left;
    width: 50%;
    padding-bottom: 1em;
  }
  .column-right {
    float: right;
    width: 50%;
    padding-bottom: 1em;
  }

  .component {
    background-color: rgb(227, 246, 255);
  }
}
</style>
