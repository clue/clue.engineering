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

> If you don't want to test this against the local container, you can optionally
> pass in a different base URL like this:
>
> ```bash
> tests/integration.bash http://clue.localhost/
> ```

Once done, you can clean up like this:

```bash
make clean
```

## Deploy

Once built (see previous "Build" section), you can simply deploy the `build/`
directory behind your favorite web server (Apache + PHP-FPM etc.).

Additionally, this should be deployed behind a reverse proxy (nginx) or CDN (Bunny CDN)
that is responsible for HTTPS certificate handling and forcing HTTPS redirects.

Additionally, Apache has been configured to cache static files for 1 day.

The live website is deployed by pushing the contents of the `build/` directory to
the `live` branch like this:

```bash
make deploy
```

## Continuous Deployment

We use continuous deployment to keep this website up to date. Any time a commit
is pushed (such as when a PR is merged), GitHub actions will automatically build
and deploy the website. This is done by running the above deployment script (see
previous chapter).

This CI/CD process requires a one-time setup that involves the following steps:
First, set up the project on the web hosting infrastructure with a `public/`
docroot. Next, configure the hosting to pull from this repository and set up a
matching read-only deploy key in this repository. Finally, set up a webhook in
this repository to trigger a deployment on any `push` event to the hosting
platform.
