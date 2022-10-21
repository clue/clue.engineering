# clue.engineering

Source code for https://clue.engineering/

## Install

Install dependencies:

```bash
composer install
```

Build website:

```bash
vendor/bin/sculpin generate
```

This will create a `build/` directory that contains the static website that can
be accessed with a web browser.

## Deploy

Then deploy `build/` behind your favorite webserver (Apache + PHP-FPM etc.).

Additionally, this should be deployed behind a reverse proxy (nginx) that is
responsible for HTTPS certificate handling and forcing HTTPS redirects.

Additionally, Apache has been configured to cache static files for 1 day.

For testing purposes, you can use the official `php` docker image like this:

```bash
docker run -it --rm -p 80:80 -v "$PWD"/build:/var/www/html php:8.1-apache sh -c "ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled; apache2-foreground"
```

## Tests

You can run some simple acceptance tests to verify the deployed website works
as expected by running:

```bash
tests/acceptance.sh https://clue.test
```

If you're using the above `php` docker image, you can run this test like this:

```bash
tests/acceptance.sh http://clue.localhost
```
