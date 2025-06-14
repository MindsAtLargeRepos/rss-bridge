#!/bin/bash
set -e

# Ensure config directory exists
mkdir -p /config

# Populate config from template with ENV variable substitution
envsubst < /config.default.ini.php > /config/config.ini.php

# Optionally copy whitelist or bridges if you bundled them
# cp -R /bridges /config/bridges

# Run the official container entrypoint
exec /usr/local/bin/docker-entrypoint.sh "$@"
