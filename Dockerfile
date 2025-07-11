FROM ruby:3.2-slim AS base

ENV BUNDLE_DEPLOYMENT=true \
    BUNDLE_PATH=/gems \
    APP_HOME=/app

# Instala dependencias del sistema
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    pkg-config \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR $APP_HOME

# Copia y instala gemas
COPY Gemfile Gemfile.lock ./
RUN gem install bundler -v 2.4.19 && \
    bundle config set without 'development test' && \
    bundle install --jobs 4 --retry 3 && \
    rm -rf /root/.bundle/cache

# Copia el resto de la app
COPY . .

# Expone el puerto de la app
EXPOSE 3006

# Usa Puma como servidor
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
