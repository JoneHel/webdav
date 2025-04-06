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

RUN mkdir -p /data && chmod 777 /data

EXPOSE 8080

ENTRYPOINT ["/bin/webdav", "--config", "/config/webdav.yml"]
