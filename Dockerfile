# builder image
FROM golang:1.16.5 as builder

WORKDIR /go/src/rest-cpu-load

# Copy all the Code and stuff to compile everything
# Will also be cached if we won't change mod/sum
COPY go.mod go.sum ./

RUN go mod download -x 

COPY . .    
    
# Builds the application as a staticly linked one, to allow it to run on alpine
RUN CGO_ENABLED=1 \
    GOOS=linux \
    GOARCH=amd64 \
    go build -a -o compiled-app -installsuffix cgo ./cmd/rest-cpu-load


FROM debian:buster-20210816-slim
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates \
    && update-ca-certificates

WORKDIR /app

EXPOSE 80
EXPOSE 8080

# `service` should be replaced here as well
COPY --from=builder /go/src/rest-cpu-load/compiled-app .

CMD ["./compiled-app"]