# Use the official Golang image as the builder
FROM golang:1.20.3-alpine as builder

# Enable CGO to use C libraries (set to 0 to disable it)
# We set it to 0 to build a fully static binary for our final image
ENV CGO_ENABLED=0

# Set the working directory
WORKDIR /app

# Copy the Go Modules manifests (go.mod and go.sum files)
COPY go.mod go.sum ./

# Download the dependencies
RUN go mod download

# Copy the source code
COPY . .

# Build the Go application and output the binary to /app/ChatGPT-Proxy-V4
RUN go build -o /app/gpt .

FROM alpine:latest

WORKDIR /app

COPY --from=builder /app/gpt /app/gpt
COPY ./docker-entrypoint.sh /app/docker-entrypoint.sh

ARG TZ="Asia/Shanghai"
ENV TZ ${TZ}

RUN apk add --no-cache bash tzdata \
    && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    && chmod +x /app/docker-entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/app/docker-entrypoint.sh"]
