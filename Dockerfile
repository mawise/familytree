FROM ruby:2.6.5-slim

# Install system dependencies
# build-essential: required for building gems with C extensions
# libsqlite3-dev: required for the sqlite3 gem
# nodejs: required for Rails asset pipeline
# graphviz: required for graph generation
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libsqlite3-dev \
    nodejs \
    graphviz \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install

# Copy the application code
COPY . .

# Set environment variable to log to stdout
ENV RAILS_LOG_TO_STDOUT=true

# Expose the server port
EXPOSE 3000

# Start the Rails server
CMD ["rails", "server", "-b", "0.0.0.0"]
