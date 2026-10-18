# base PHP version for the build and final project
FROM php:8.1-apache AS php-version

# base composer stage to install dependencies
FROM composer:2 AS vendor
COPY composer.json composer.lock ./
RUN composer install --ignore-platform-reqs --optimize-autoloader

# final tailwind sidecar stage
FROM alpine:3 AS tailwind
RUN apk --no-cache add libstdc++
WORKDIR /app/
ADD --checksum=sha256:a04d34ceacc8f52cbe8920ad846cdeb61d3d0021dba32db0d1f77c9d9fad7a6c --chmod=0755 \
    https://github.com/tailwindlabs/tailwindcss/releases/download/v4.3.3/tailwindcss-linux-x64-musl /usr/local/bin/tailwindcss
ENTRYPOINT ["tailwindcss", "-i", "tailwind.css"]

# base sculpin stage to generate the static website
FROM php-version AS sculpin
WORKDIR /app/
COPY --from=vendor /app/vendor/ vendor/
COPY app/ app/
COPY www/ www/
RUN vendor/bin/sculpin generate

# final build stage with the static website only, exported by `make build`
FROM scratch AS build
COPY --from=sculpin /app/build/ /

# final project stage
FROM php-version
RUN ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-available/headers.load /etc/apache2/mods-enabled
COPY --from=build / /var/www/html/
HEALTHCHECK --start-period=1m --start-interval=0.1s --interval=1h \
    CMD ["curl", "-I", "--no-progress-meter", "http://localhost/"]
