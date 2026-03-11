FROM node:20.19.5-alpine3.21 AS build

WORKDIR /opt/server

COPY package.json .
COPY *.js .

# Install dependencies
RUN npm install

# Update packages and clean cache
RUN apk update && apk upgrade && \
    rm -rf /var/cache/apk/*


FROM node:20.19.5-alpine3.21

WORKDIR /opt/server

# Create user and group
RUN addgroup -S roboshop && \
    adduser -S roboshop -G roboshop && \
    chown -R roboshop:roboshop /opt/server

EXPOSE 8080

LABEL com.project="roboshop" \
      component="catalogue" \
      created_by="sivakumar"

ENV MONGO="true" \
    MONGO_URL="mongodb://mongodb:27017/catalogue"

COPY --from=build --chown=roboshop:roboshop /opt/server /opt/server

USER roboshop

ENTRYPOINT ["node"]
CMD ["server.js"]