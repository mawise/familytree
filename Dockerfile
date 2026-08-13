FROM ruby:2.6.5-slim

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    build-essential \
    libsqlite3-dev \
    nodejs \
    graphviz \
    pkg-config && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install gems
COPY Gemfile Gemfile.lock ./
RUN gem install bundler -v 2.4.22 && bundle install

# Copy application code
COPY . .

# Precompile assets for production
RUN RAILS_ENV=production SECRET_KEY_BASE=dummy bundle exec rake assets:precompile

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0", "-p", "3000"]
