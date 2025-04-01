FROM golang:1.24-alpine AS build
WORKDIR /go/src/app

COPY go.mod ./
RUN go mod download

COPY src/ ./src
RUN CGO_ENABLED=0 go build -o /go/bin/main ./src/main.go

FROM gcr.io/distroless/static-debian12:nonroot-amd64

COPY --from=build /go/bin/main /
ENTRYPOINT ["/main"]
