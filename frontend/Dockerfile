FROM node:14.13.0-alpine as build-stage

WORKDIR /srv/app
ADD . /srv/app
RUN npm install
RUN npm run build

FROM nginx:stable-alpine as production-stage
COPY --from=build-stage /srv/app/dist /usr/share/nginx/html
CMD ["nginx", "-g", "daemon off;"]