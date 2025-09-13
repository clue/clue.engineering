# syntax=docker/dockerfile:1
FROM composer:2 AS composer
WORKDIR /app/
COPY composer.json composer.lock ./
RUN composer install --ignore-platform-reqs --optimize-autoloader

FROM scratch AS tailwind
WORKDIR /app/
ADD --checksum=sha256:cd52e757cb0bd15238f0207a215198d924811234028d056b7be39fde70491296 --chmod=0755 \
    https://github.com/tailwindlabs/tailwindcss/releases/download/v3.2.4/tailwindcss-linux-x64 /usr/local/bin/tailwindcss
ENTRYPOINT ["tailwindcss"]

FROM php:8.1-apache AS build
WORKDIR /app/
COPY --from=composer /app/vendor/ vendor/
COPY app/ app/
COPY www/ www/
RUN vendor/bin/sculpin generate

FROM php:8.1-apache
RUN ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled
COPY --from=build /app/build/ /var/www/html/
HEALTHCHECK --start-period=1m --start-interval=0.1s --interval=1h \
    CMD ["curl", "-I", "--no-progress-meter", "http://localhost/"]
