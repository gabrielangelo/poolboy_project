# Use the official Elixir image with Erlang/OTP 24
FROM hexpm/elixir:1.13.3-erlang-24.2.1-debian-bullseye-20210902-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the Elixir project files into the container
COPY . .

# Install hex and rebar for dependency management
RUN mix local.hex --force && \
    mix local.rebar --force

# Fetch and compile the dependencies
RUN mix deps.get --only prod
RUN mix deps.compile

# Compile the application
RUN mix compile

# Set the environment to production
ENV MIX_ENV=dev

# Run the application
CMD ["mix", "run", "--no-halt"]
