FROM ruby:2.6-slim
WORKDIR /app

RUN echo "deb http://archive.debian.org/debian bullseye main" > /etc/apt/sources.list \
    && apt-get update -o Acquire::Check-Valid-Until=false -qq \
    && apt-get install -yqq --no-install-recommends \
       autoconf build-essential bison \
       build-essential libssl-dev libyaml-dev libreadline6-dev \
       zlib1g-dev libncurses5-dev libffi-dev libgdbm-dev git libgdbm6 libreadline-dev \
       nginx nodejs dirmngr gnupg apt-transport-https ca-certificates npm imagemagick \
       postgresql postgresql-contrib libpq-dev cron shared-mime-info graphviz && \
    npm install --global yarn && \
    gem update --system 3.4.22 --no-document && \
    gem install bundler -v 2.4.12 --no-document && \
    rm -rf /var/lib/apt/lists/*

ADD Gemfile Gemfile.lock Rakefile config.ru .ruby-version .

# Setting MALLOC_ARENA_MAX to 2 can greatly reduce memory usage
ENV MALLOC_ARENA_MAX='2'

ENV RAILS_ENV=production
ENV RAILS_SERVE_STATIC_FILES=true

RUN bundle config build.bcrypt --use-system-libraries && \
    bundle config set --local deployment 'true' && \
    bundle config set --local without 'development test'
RUN bundle install

ADD . .
RUN bin/rails assets:precompile

EXPOSE 3001

CMD ["bash", "./bin/docker-start"]
