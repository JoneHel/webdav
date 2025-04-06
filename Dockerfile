FROM golang:1.24-alpine3.20 AS build

WORKDIR /webdav

COPY ./go.mod ./go.sum ./
RUN go mod download

COPY . .

RUN go build -o main .

# Final image (slim and secure)
FROM alpine

COPY --from=build /webdav/main /bin/webdav
COPY --from=build /webdav/webdav.yml /config/webdav.yml

# Ensure mount point exists and give all permissions (redundant for mount but safe fallback)
RUN mkdir -p /webdav_data && chmod -R 777 /webdav_data

# 🔑 Set user to root (UID 0) — ensures permission to write to Railway volume
USER 0

EXPOSE 8080

ENTRYPOINT ["/bin/webdav", "--config", "/config/webdav.yml"]
