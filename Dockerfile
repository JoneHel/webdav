FROM golang:1.24-alpine3.20 AS build

ARG VERSION="untracked"

RUN apk --update add ca-certificates

WORKDIR /webdav/

COPY ./go.mod ./
COPY ./go.sum ./
RUN go mod download

COPY . /webdav/
RUN go build -o main -trimpath -ldflags="-s -w -X 'github.com/hacdias/webdav/v5/cmd.version=$VERSION'" .

FROM scratch

COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=build /webdav/main /bin/webdav
COPY webdav.yml /config/webdav.yml
COPY htpasswd /config/htpasswd

EXPOSE 8080

ENTRYPOINT ["webdav", "--config", "/config/webdav.yml"]


