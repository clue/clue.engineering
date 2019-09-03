# clue.engineering

Source code for https://clue.engineering/

Install dependencies:

```bash
$ composer install
```

Build website:

```bash
$ vendor/bin/sculpin generate --source-dir=www --output-dir=build
```

Then deploy `build/` behind your favorite webserver.
