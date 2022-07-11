---
title: Happy birthday ReactPHP – announcing the future of async with fibers!
social_image_large: https://clue.engineering/src/2022-reactphp-birthday.png
tags:
  - reactphp
  - release
  - birthday
  - fibers
author:
  - Christian Lück
---

![ReactPHP – 10 years](../src/2022-reactphp-birthday.png)

Today marks ReactPHP’s 10th birthday. 🎉
To celebrate, we’re thrilled to announce the immediate availability of our [all-new Async component](https://reactphp.org/async/) using **fibers in PHP 8.1+**. By taking advantage of fibers, we’re making a big step forward for the future of async PHP and bringing new APIs that allow us to say **ReactPHP has never been better**!

Today we’re releasing several new major versions!
We’ve been busy bees to not only support the latest PHP language features but also provide a smooth upgrade path for older versions:

- [**Async `v4.0.0`**](https://reactphp.org/async/) (PHP 8.1+)
- [Async `v3.0.0`](https://github.com/reactphp/async/tree/3.x) (PHP 7.1+)
- [Async `v2.0.0`](https://github.com/reactphp/async/tree/2.x) (PHP 5.3+)
- [ReactPHP meta-package `v1.3.0`](https://github.com/reactphp/reactphp)

You can check the [ReactPHP changelog](https://reactphp.org/changelog.html) for all the details,
but here’s the gist of why we’re enthusiastic to ring in the next generation of async PHP:

## Async PHP with async & await

We’re especially excited about built-in support for fibers with the [all-new Aync component](https://reactphp.org/async/).
We believe this is a game-changer for the asynchronous PHP landscape.
It provides a simple, composable, and consistent API for asynchronous programming in PHP.
This makes it easy to write asynchronous code that is both super fast and easy to understand.

```php
<?php

// $ composer require react/http react/async

use React\Http\Browser;
use function React\Async\await;

require __DIR__ . '/vendor/autoload.php';

$url = $argv[1] ?? 'https://reactphp.org/';
$browser = new Browser();

try {
    $response = await($browser->get($url));
    echo (string) $response->getBody();
} catch (Exception $e) {
    echo 'Error: ' . $e->getMessage() . PHP_EOL;
}
```

This example only covers the basics, but it’s easy to see how the new [`async()`](https://reactphp.org/async/#async) and [`await()`](https://reactphp.org/async/#await) functions make writing asynchronous PHP a breeze.
They allow us to express the program flow in a way that we don’t have to deal with the intricacies of async execution anymore.

In other words, async programs will start to look no more complex than their synchronous counterparts.
PHP 8.1+ provides built-in support for fibers which these functions use internally, so you don’t have to worry about the [low-level details](../2021/fibers-in-php).
What’s best, we went the extra mile to ensure the above example works across all PHP versions, so we can provide a smooth upgrade path to the future of async PHP for everybody.

## Nextgen ReactPHP

The ReactPHP ecosystem is constantly growing and more and more projects and companies start seeing the advantages async PHP has to offer.
Ten years ago, on 11th July 2012, the [first beta release](https://reactphp.org/changelog.html#eventloop-010-2012-07-11) of ReactPHP was tagged.
Fast forward to today, we’ve come a long way and ReactPHP is used in countless projects all over the world.
With millions of downloads each month, ReactPHP has become one of the leading projects to build async PHP applications.

The new [Async component](https://reactphp.org/async/) marks a major milestone and is a game-changer for upcoming applications.
This makes it easier than ever to develop async PHP applications and we believe this opens up new possibilities for the async PHP ecosystem and will allow ReactPHP to thrive.
We will continue our long-term support (LTS) promise and will continue supporting the current version for the foreseeable future.
On top of this, this release marks the starting point for future development in ReactPHP to explore newer language-level features and improved type safety.
Hello ReactPHP v3, I’m sure we’ll hear more about this in the (near) future!

Thank you to everyone who has contributed to ReactPHP over the years, whether it’s been through code contributions, publishing blog posts and videos, helping with the documentation, answering questions on the issue tracker or chat, or just spreading the word about ReactPHP.

*It’s been an amazing ride so far and we’re excited to see what the future brings!
Happy birthday and here’s to another ten years of asynchronous PHP with [ReactPHP](https://reactphp.org/)!* 🎉💥
