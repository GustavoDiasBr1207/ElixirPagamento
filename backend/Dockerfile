FROM elixir:1.16.2-otp-25-alpine

WORKDIR /app

# Install build dependencies
RUN apk add --no-cache build-base postgresql-client

# Copy mix files
COPY mix.exs mix.lock ./

# Install dependencies
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get && \
    mix deps.compile

# Copy application code
COPY . .

# Build assets
RUN mix assets.build

# Expose port
EXPOSE 4000

# Run server
CMD ["mix", "phx.server"]
