# build stage
FROM node:lts-alpine as build-stage
ENV VUE_APP_BACKEND_URL https://mapwhere-backend.herokuapp.com
ENV VUE_APP_MAPS_API_KEY AIzaSyCGFVWnH0vevBPG52s3iYsCRJoEMBpryjk
ENV VUE_APP_FIREBASE_API_KEY AIzaSyC0oQAyJN_42wFRvpVxpsu1MbH3-f-y5cY
ENV VUE_APP_FIREBASE_AUTH_DOMAIN mapwhere-be05d.firebaseapp.com
ENV VUE_APP_FIREBASE_PROJECT_ID mapwhere-be05d
ENV VUE_APP_FIREBASE_STORAGE_BUCKET mapwhere-be05d.appspot.com
ENV VUE_APP_FIREBASE_MESSAGING_SENDER_ID 39854944278
ENV VUE_APP_FIREBASE_APP_ID 1:39854944278:web:f4ed946900bfbabdfcc537
ENV VUE_APP_FIREBASE_MEASUREMENT_ID G-FBK4WS80F7
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# production stage
FROM nginx:stable-alpine as production-stage
COPY nginx.conf /etc/nginx/conf.d/configfile.template
COPY --from=build-stage /app/dist /usr/share/nginx/html
ENV PORT 8080
ENV HOST 0.0.0.0
EXPOSE 8080
CMD sh -c "envsubst '\$PORT' < /etc/nginx/conf.d/configfile.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"
