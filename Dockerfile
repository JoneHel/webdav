# ------------------------------------------
# 1) BUILD STAGE
# ------------------------------------------
FROM golang:1.24-alpine3.20 AS build

# Set a working directory where we'll build the project
WORKDIR /webdav

# Copy the Go module files first so we can cache 'go mod download'
COPY go.mod go.sum ./
RUN go mod download

# Copy the remaining files into the build context
COPY . .

# Build the main binary
RUN go build -o main .

# ------------------------------------------
# 2) FINAL STAGE
# ------------------------------------------
FROM alpine:latest

# Install any runtime dependencies (bash, certificates if needed)
RUN apk add --no-cache bash ca-certificates

# Create the directory we want to serve via WebDAV; set permissions.
RUN mkdir -p /webdav_data && chmod 777 /webdav_data

# Copy the built binary from the build stage
COPY --from=build /webdav/main /bin/webdav

# Copy your webdav.yml config into the container
COPY --from=build /webdav/webdav.yml /config/webdav.yml

# (Optional) If you want hacdias/webdav to auto-detect the config via env var
ENV WEBDAV_CONFIG=/config/webdav.yml

# Expose port 8080 to match what's in your webdav.yml (address: 0.0.0.0, port: 8080)
EXPOSE 8080

# CMD to actually run the WebDAV server with your config
CMD ["/bin/webdav", "--config", "/config/webdav.yml"]
