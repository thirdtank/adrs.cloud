FROM docker.io/library/ruby:3.3-slim as base

WORKDIR /brut-app

# Install base packages
#
# - ca-certificates is needed for other installs 
# - curl is needed generally for other installs and by Heroku
# - gnupg is a PGP replacement used in making sure new APT repos work
# - libjemalloc2 in theory speeds up Ruby
# - lsb-release is used to generically access information for this OS's version
# - wget allows us to copy/paste commands from vendors about how to install
#   software even though it does the same thing as curl
RUN apt-get update --quiet --yes && \
    apt-get install --no-install-recommends --quiet --yes \
      ca-certificates \
      curl \
      gnupg \
      libjemalloc2 \
      lsb-release \
      wget && \
		rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install the PostgreSQL client.  The latest version is not available
# from Debian, so we set up our own.
#
# - lsb-release is needed to generalize the command to set up the new APT repo that contains Postgres
# - gnupg is needed to assert
#
# Based on: https://www.postgresql.org/download/linux/debian/
RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    apt-get update && \
    apt-get --yes --quiet install postgresql-client-16 && \
		rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set basic env vars for production
ENV RACK_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

# Throw-away build stage to reduce size of final image
FROM base AS build

RUN apt-get update --quiet --yes && \
    apt-get install --no-install-recommends --quiet --yes \
			build-essential \
			git \
      libpq-dev \
			pkg-config

# Install Node and NPM
# https://github.com/nodesource/distributions#using-debian-as-root-nodejs-20
RUN curl -fsSL https://deb.nodesource.com/setup_20.x -o nodesource_setup.sh && \
    bash nodesource_setup.sh && \
    apt-get install -y nodejs

# Copy the app
COPY . .
# Install RubyGems
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# Install Node Modules
RUN npm clean-install

# Build all assets
RUN bin/build && rm -rf node_modules

FROM base
# Copy built artifacts: gems, application
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /brut-app /brut-app

# For security, set directories that will be written to be owned by non-root
RUN groupadd --system --gid 1000 brut && \
    useradd brut --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R brut:brut logs tmp
USER 1000:1000

ENTRYPOINT ["/brut-app/deploy/docker-entrypoint"]


# vim: ft=Dockerfile
