# syntax=docker/dockerfile:1
FROM composer:2 AS composer
WORKDIR /app/
COPY composer.json composer.lock ./
RUN composer install --ignore-platform-reqs --optimize-autoloader

FROM alpine:3 AS tailwind
RUN apk --no-cache add libstdc++
WORKDIR /app/
ADD --checksum=sha256:a04d34ceacc8f52cbe8920ad846cdeb61d3d0021dba32db0d1f77c9d9fad7a6c --chmod=0755 \
    https://github.com/tailwindlabs/tailwindcss/releases/download/v4.3.3/tailwindcss-linux-x64-musl /usr/local/bin/tailwindcss
ENTRYPOINT ["tailwindcss", "-i", "tailwind.css"]

FROM php:8.1-apache AS build
WORKDIR /app/
COPY --from=composer /app/vendor/ vendor/
COPY app/ app/
COPY www/ www/
RUN vendor/bin/sculpin generate

FROM php:8.1-apache
RUN ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-available/headers.load /etc/apache2/mods-enabled
COPY --from=build /app/build/ /var/www/html/
HEALTHCHECK --start-period=1m --start-interval=0.1s --interval=1h \
    CMD ["curl", "-I", "--no-progress-meter", "http://localhost/"]
