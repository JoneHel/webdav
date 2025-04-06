FROM golang:1.24-alpine3.20 AS build
LABEL force_rebuild="true-20250406-1558"

ARG VERSION="untracked"

RUN apk --update add ca-certificates

WORKDIR /webdav/

COPY ./go.mod ./
COPY ./go.sum ./
RUN go mod download

COPY . /webdav/
RUN go build -o main -trimpath -ldflags="-s -w -X 'github.com/hacdias/webdav/v5/cmd.version=$VERSION'" .

RUN echo "🧪 DEBUG: LISTING FILES IN BUILD CONTEXT" && ls -l /webdav && \
    echo "🧪 DEBUG: PRINTING webdav.yml" && cat /webdav/webdav.yml && \
    echo "🧪 DEBUG: PRINTING htpasswd" && cat /webdav/htpasswd
    
FROM scratch

COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=build /webdav/main /bin/webdav
COPY ./htpasswd /config/htpasswd
COPY ./webdav.yml /config/webdav.yml


ENTRYPOINT ["/bin/webdav", "--config", "/config/webdav.yml"]





