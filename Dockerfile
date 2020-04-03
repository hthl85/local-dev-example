###############################################################################
# Phrase - Base
###############################################################################

# Default docker image for base
ARG BUILDER_IMG=golang
ARG BUILDER_TAG=1.13.8-alpine3.11
ARG CERT_IMG=alpine
ARG CERT_TAG=3.11.3

FROM ${BUILDER_IMG}:${BUILDER_TAG} as base

# All remain docker arguments
ARG PORT=8080

# Set work directory
WORKDIR /app

# Set environment values
ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64

# Copy go module
COPY go.mod .

# Build application
RUN go mod download

###############################################################################
# Phrase - Build
###############################################################################

FROM base AS builder
COPY . .
RUN go build -o app

###############################################################################
# Phrase - Certs
###############################################################################

FROM ${CERT_IMG}:${CERT_TAG} as certs
RUN apk --update add ca-certificates

###############################################################################
# Phrase - App
###############################################################################

FROM scratch as app
COPY --from=certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=builder app /

EXPOSE $PORT

ENTRYPOINT ["/app"]
