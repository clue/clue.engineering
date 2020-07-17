# clue.engineering

Source code for https://clue.engineering/

## Install

Install dependencies:

```bash
$ composer install
```

Build website:

```bash
$ vendor/bin/sculpin generate
```

## Deploy

Then deploy `build/` behind your favorite webserver (Apache + PHP-FPM etc.).

Additionally, this should be deployed behind a reverse proxy (nginx) that is
responsible for HTTPS certificate handling and forcing HTTPS redirects.

## Tests

You can run some simple acceptance tests to verify the deployed website works
as expected by running:

```bash
$ tests/acceptance.sh https://clue.test
```
