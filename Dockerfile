FROM debian:12-slim AS rssbridge

LABEL description="RSS-Bridge is a PHP project capable of generating RSS and Atom feeds for websites that don't have one."
LABEL repository="https://github.com/RSS-Bridge/rss-bridge"
LABEL website="https://github.com/RSS-Bridge/rss-bridge"

ARG DEBIAN_FRONTEND=noninteractive
RUN set -xe && \
    apt-get update && \
    apt-get install --yes --no-install-recommends \
      ca-certificates \
      nginx \
      nss-plugin-pem \
      php-curl \
      php-fpm \
      php-intl \
      php-mbstring \
      php-memcached \
      php-sqlite3 \
      php-xml \
      php-zip \
      curl \
      patchelf \
    && \
    curlimpersonate_version=1.0.0rc2 && \
    # (curl-impersonate installation logic remains unchanged) \
    curl -LO "https://github.com/lexiforest/curl-impersonate/releases/download/v${curlimpersonate_version}/${archive}" && \
    echo "$sha512sum  $archive" | sha512sum -c - && \
    mkdir -p /usr/local/lib/curl-impersonate && \
    tar xaf "$archive" -C /usr/local/lib/curl-impersonate && \
    patchelf --set-soname libcurl.so.4 /usr/local/lib/curl-impersonate/libcurl-impersonate.so && \
    rm "$archive" && \
    apt-get purge --assume-yes curl patchelf && \
    rm -rf /var/lib/apt/lists/*

ENV LD_PRELOAD /usr/local/lib/curl-impersonate/libcurl-impersonate.so
ENV CURL_IMPERSONATE chrome131

# Pipe logs to stdout/stderr
RUN ln -sfT /dev/stderr /var/log/nginx/error.log && \
    ln -sfT /dev/stdout /var/log/nginx/access.log && \
    chown -R --no-dereference www-data:adm /var/log/nginx/

# Copy configuration files
COPY ./config/nginx.conf /etc/nginx/sites-available/default
COPY ./config/php-fpm.conf /etc/php/8.2/fpm/pool.d/rss-bridge.conf
COPY ./config/php.ini /etc/php/8.2/fpm/conf.d/90-rss-bridge.ini

# Copy the app source
COPY --chown=www-data:www-data ./ /app/

# ⚠️ Add your custom entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 80
