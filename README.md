# clue.engineering

Source code for https://clue.engineering/

Install dependencies:

```bash
$ composer install
```

Build website:

```bash
$ vendor/bin/sculpin generate
```

Then deploy `build/` behind your favorite webserver (Apache + PHP-FPM etc.).

You can run some simple acceptance tests to verify the deployed website works
as expected by running:

```bash
$ tests/acceptance.sh https://clue.test
```
