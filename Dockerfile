FROM node:alpine as build
WORKDIR /app

RUN apk --update add git less openssh && \
    rm -rf /var/lib/apt/lists/* && \
    rm /var/cache/apk/*
COPY package.json package.json
RUN npm install --production
COPY . .
RUN rm config/default.json
RUN mv config/docker.json config/default.json
RUN rm package-lock.json

# create runtime
FROM --platform=$BUILDPLATFORM node:alpine as runtime
WORKDIR /app
VOLUME [ "/config", "/commands" ]
EXPOSE 3000 3001

ENV NODE_CONFIG_DIR=/app/config:/config

COPY --from=build /app .

ENTRYPOINT ["npm", "run", "production"]