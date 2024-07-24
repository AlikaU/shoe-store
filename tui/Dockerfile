FROM golang:1.22 as builder
WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN go build -o shoe_store_ui .

# restart from scratch in debian
FROM debian:stable-slim
COPY --from=builder /app/shoe_store_ui .

# without this, it becomes black and white
ENV TERM xterm-256color
ENV COLORTERM truecolor

CMD ["./shoe_store_ui"]
