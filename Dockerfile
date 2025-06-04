FROM golang:1.21.5-alpine AS builder
WORKDIR /app
COPY api/go.mod api/go.sum ./
RUN go mod download
COPY api .
RUN CGO_ENABLED=0 GOOS=linux go build -o /bin/app ./cmd/demo/main.go

FROM alpine:3.18
WORKDIR /app
COPY --from=builder /bin/app .
ENV API_PORT=8080 \
    DB_URL="postgres://USER_DB:PWD_DB@postgres:5432/DB"
EXPOSE 8080
CMD ["./app"]
