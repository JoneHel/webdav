FROM golang:1.24-alpine3.20 AS build

WORKDIR /webdav

COPY ./go.mod ./go.sum ./
RUN go mod download

COPY . .

RUN go build -o main .

# ✅ Runtime container
FROM alpine

# Install busybox (basic tools) just in case
RUN apk add --no-cache bash

COPY --from=build /webdav/main /bin/webdav
COPY --from=build /webdav/webdav.yml /config/webdav.yml

# 🔑 Set user as root
USER 0

# ✅ Make sure mount point exists (will be overridden by Railway but harmless)
RUN mkdir -p /webdav_data && chmod 777 /webdav_data

EXPOSE 8080

ENTRYPOINT ["/bin/webdav", "--config", "/config/webdav.yml"]
