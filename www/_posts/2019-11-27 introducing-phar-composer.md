---
title: Introducing zero-config phar creation for every PHP project
social_image: https://user-images.githubusercontent.com/776829/69410647-c0488180-0d0b-11ea-915f-0b0908b75338.jpg
tags:
 - introducing
 - phar
 - composer
 - package
 - bundle
 - build
 - php
author:
  - Christian Lück
---

![Symbolic image of a box that's not an actual Phar, original photo by Kelli McClintock](https://user-images.githubusercontent.com/776829/69410647-c0488180-0d0b-11ea-915f-0b0908b75338.jpg)
<!-- Photo by [Kelli McClintock](https://unsplash.com/@kelli_mcclintock?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText) on [Unsplash](https://unsplash.com/photos/GopRYASfsOc) -->

Last week, I've released `v1.1.0` of [clue/phar-composer](https://github.com/clue/phar-composer): it allows simple phar (php archive) creation for every PHP project managed via Composer.
It takes any PHP project as input and turns its project directory and all its vendor files into a single Phar file which allows easy distribution. This is particularly useful for CLI applications, but it can equally be used to bundle any PHP web application.

The new version brings up-to-date dependency support (including support for Symfony 5), significantly improves performance and fixes a number of minor issues when bundling less common project setups. If you care about the details what has changed, take a look at its [release history](https://github.com/clue/phar-composer/releases), otherwise keep reading.

## Quickstart

Now let's get this up and running for a quick demo project. The recommended way to install this project it by downloading the ready-to-use version as a Phar to any directory like this:

```bash
$ curl -JOL https://clue.engineering/phar-composer-latest.phar
```

That's it already. Once downloaded, you can now use `build` command to build an executable single-file phar for any project managed by Composer:

```bash
$ php phar-composer-1.1.0.phar build ~/workspace/acme
```

After a second or two, it should report that it successfully created your `acme.phar` output file. You can now upload this build artefact to your GitHub releases or host this on your website for quick download. This is everything you need to know to get you started shipping phar files for distribution.

If you want to install phar-composer as a more permanent solution for your project, you may want to check out the documentation to [install phar-composer as a `dev` dependency](https://github.com/clue/phar-composer#installation-using-composer).
Once this is done, you may consider adding a simple build script so that building your phar becomes as easy as running `composer build`. For inspiration, feel free to check out the included build script which we use to bundle the phar-composer release itself with phar-composer.

## Looking forward

One of the most exciting features of phar-composer is how it's incredibly boring: It just works. And in fact, it hasn't changed much in 6+ years. It takes your project directory and turns it into a single phar file that can be distributed easily.

In the future, I'm planning to bring in some features to provide better, more opinionated defaults out-of-the-box.
For instance, excluding any `dev` dependencies currently requires an explicit build script to run a `composer install --no-dev` in a temporary project directory.
Among other changes, we're planning to make this the default.

If you want to learn more about the project and see how it could be useful for your project, check out its [project homepage](https://github.com/clue/phar-composer).
Its documentation covers all the details and if you still have any questions or remarks, make sure to let me know: Send a tweet or comment this blog post. Cheers 🍻

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">Released v1.1.0 of clue/phar-composer: simple phar (php archive) creation for every PHP project managed via <a href="https://twitter.com/hashtag/ComposerPHP?src=hash&amp;ref_src=twsrc%5Etfw">#ComposerPHP</a>. Significant performance improvements, <a href="https://twitter.com/symfony?ref_src=twsrc%5Etfw">@symfony</a> 5 support and more 🐘📦📈 <a href="https://twitter.com/hashtag/php?src=hash&amp;ref_src=twsrc%5Etfw">#php</a> <a href="https://twitter.com/hashtag/archive?src=hash&amp;ref_src=twsrc%5Etfw">#archive</a> <a href="https://twitter.com/hashtag/bundle?src=hash&amp;ref_src=twsrc%5Etfw">#bundle</a> <a href="https://t.co/aIhffnOfAx">https://t.co/aIhffnOfAx</a></p>&mdash; Christian Lück (@another_clue) <a href="https://twitter.com/another_clue/status/1199727438718259200?ref_src=twsrc%5Etfw">November 27, 2019</a></blockquote>
