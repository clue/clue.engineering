# clue.engineering

[![CI status](https://github.com/clue/clue.engineering/actions/workflows/ci.yml/badge.svg)](https://github.com/clue/clue.engineering/actions)
[![Last deployed on `live`](https://img.shields.io/github/last-commit/clue/clue.engineering/live?label=last%20deployed&logo=github)](https://github.com/clue/clue.engineering/tree/live)

Source code for the https://clue.engineering/ website.

## Build

You can build the website like this:

```bash
make
```

Once built, you can manually browse the `build/` directory or run the web server
container (Apache) in the foreground like this:

```bash
make serve
```

Alternatively, you may also run the web server container (Apache) as a
background daemon like this:

```bash
make served
```

Once running, you can run some integration tests that check correct paths etc.
like this:

```bash
make test
```

> This test assumes you're running the above web server container on
> `http://clue.localhost`. You may test other deployments like this:
>
> ```bash
> tests/integration.bash https://clue.example
> ```

Once done, you can clean up like this:

```bash
make clean
```

## Deploy

Once built (see previous "Build" section), you can simply deploy the `build/`
directory behind your favorite web server (Apache + PHP-FPM etc.).

Additionally, this should be deployed behind a reverse proxy (nginx) that is
responsible for HTTPS certificate handling and forcing HTTPS redirects.

Additionally, Apache has been configured to cache static files for 1 day.

The live website is deployed by pushing the contents of the `build/` directory to
the `live` branch like this:

```bash
make deploy
```

## Auto-Deployment

Any time a commit is merged (such as when a PR is merged), GitHub actions will
automatically build and deploy the website. This is done by running the above
deployment script (see previous chapter).
