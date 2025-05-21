# Multi stage building strategy for reducing image size.
FROM golang:1.22.3-alpine3.19 AS build-env
# FROM 339388639205.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-base:golang-1.22.3-alpine3.19 AS build-env
ENV GO111MODULE=on
RUN mkdir /app
WORKDIR /app

# Install each dependencies
COPY go.mod /app
COPY go.sum /app
RUN go mod download
RUN apk add --no-cache --virtual git gcc make build-base alpine-sdk

# COPY main module
COPY . /app

# Check and Build
RUN go get golang.org/x/lint/golint && \
    make validate && \
    make build-linux

### If use TLS connection in container, add ca-certificates following command.
### > RUN apk add --no-cache ca-certificates
# FROM gcr.io/distroless/base-debian10
FROM alpine:3.19
# FROM 339388639205.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-base:alpine-3.19
COPY --from=build-env /app/main /
EXPOSE 80
ENTRYPOINT ["/main"]
