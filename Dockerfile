# --- Build Stage ---
FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o /app/torrengo .

# --- Final Stage ---
FROM alpine:latest
RUN apk add --no-cache chromium
RUN ln -s /usr/bin/chromium-browser /usr/bin/google-chrome
WORKDIR /app
COPY --from=builder /app/torrengo .
WORKDIR /downloads
ENTRYPOINT ["/bin/sh", "-c", "chromium-browser --headless --no-sandbox --disable-gpu --remote-debugging-port=9222 2>/dev/null & sleep 2 && /app/torrengo \"$@\"", "sh"]