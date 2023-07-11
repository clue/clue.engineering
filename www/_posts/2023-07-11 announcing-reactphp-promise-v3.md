---
title: Happy birthday ReactPHP – releasing new Promise v3!
social_image_large: https://clue.engineering/src/2023-reactphp-birthday.png
tags:
  - reactphp
  - release
  - birthday
  - promise
author:
  - Christian Lück
  - Simon Frings
---

![ReactPHP – 11 years](../src/2023-reactphp-birthday.png)

Today marks **ReactPHP’s 11th birthday**. 🎉 To celebrate this special day together with all of you, we are thrilled to announce the release of the highly anticipated [v3.0.0 of our Promise component](https://reactphp.org/promise/). This major version has been in the works since 2016 and marks the starting point for a bigger, better and brighter future for the whole ReactPHP ecosystem.

The new Promise version comes with a bunch of improvements to enhance the user experience with ReactPHP. You can check out the full [ReactPHP changelog](https://reactphp.org/changelog.html) for all the details, but here's a quick overview of the key highlights:

### Better error reporting for unhandled rejections

Over the years we have received a lot of questions and feedback from the community, particularly regarding better insights when things go wrong. In previous versions, if exceptions or errors were thrown inside a promise callback and not being handled properly, they would be discarded without the user being aware of them. This has caused a great deal of confusion in the past, but things are about to change.

With the introduction of Promise v3, all unhandled promise rejections will be reported and logged as error messages by default:

```php
// Unhandled promise rejection with RuntimeException: Unhandled in example.php:2
reject(new RuntimeException('Unhandled'));
```

By gaining a better understanding of the problem, finding a solution becomes much easier and quicker, thus greatly improving the developer experience with Promise v3. And if you want more control over the default behavior, we've got you covered with a new [`set_rejection_handler()` function](https://reactphp.org/promise/#set_rejection_handler) to adjust this to your needs.

### Type safe APIs

We now take advantage of native PHP type declarations consistently for our APIs. By ensuring type safety for promises, we can assist IDEs, static analysis tools and *humans* alike, which allows everybody to write code with greater confidence. Long overdue, this will also raise the minimum supported PHP version to PHP 7.1+ with PHP 8.1+ recommended for best performance.

To achieve even better type safety, we also now leverage PHPStan template types. This means PHPStan can now help you detect this code as invalid:

```php
/** @return PromiseInterface<int> */
function answer(): PromiseInterface
{
    return resolve(42);
}

// PHPStan now detects the following line as invalid
answer()->then(function (bool $result): string {
    return 'Can you also tell what is wrong?';
});
```

Fun note: PHPStan uses ReactPHP internally for faster execution – and we're now using PHPStan in ReactPHP for faster development. If you also want to take advantage of the type-safe Promise API, we can highly recommend giving [PHPStan](https://phpstan.org/) a try.

### Improved API, removed deprecations, and more

The release of a new major version presents an excellent opportunity to improve APIs and implement some much-desired changes. Among others, we've used this opportunity to bring our APIs more in line with the ES6 Promise specification as found in JavaScript. This includes a number of API changes that may introduce minor BC breaks such as the following:

```php
// old (arguments used to be optional)
$promise = resolve();
$promise = reject();

// new (already supported before)
$promise = resolve(null);
$promise = reject(new RuntimeException());
```

On top of this, we've simplified our APIs by merging `CancellablePromiseInterface` and `ExtendedPromiseInterface` into a single `PromiseInterface` for your convenience. Thanks to the updated PHP language support, we can now provide `catch()` and `finally()` methods like this:

```php
// old (multiple interfaces may or may not be implemented)
assert($promise instanceof PromiseInterface);
assert(method_exists($promise, 'then'));
if ($promise instanceof ExtendedPromiseInterface) {
    assert(method_exists($promise, 'otherwise'));
    assert(method_exists($promise, 'always'));
}
if ($promise instanceof CancellablePromiseInterface) {
    assert(method_exists($promise, 'cancel'));
}

// new (single PromiseInterface with all methods)
assert($promise instanceof PromiseInterface);
assert(method_exists($promise, 'then'));
assert(method_exists($promise, 'catch'));
assert(method_exists($promise, 'finally'));
assert(method_exists($promise, 'cancel'));
```

Most of these changes should be fairly straightforward, but if you're upgrading from an older version, you may want to check out the [Promise `v3.0.0` changelog](https://reactphp.org/promise/changelog.html#300-2023-07-11) for all detailed changes.

In this context, we have also released a new [reactphp/reactphp `v1.4.0`](https://github.com/reactphp/reactphp) meta package. This meta package will install all stable components at once, and it now also includes our updated Promise v3 component. Happy prototyping!

### Looking forward

We are proud to announce that Promise v3 is now live, marking the next major step toward the upcoming release of ReactPHP v3. Promise v3 provides a glimpse into what a more modern ReactPHP can look like, making development with ReactPHP much easier, significantly faster and *more awesome*.

After being in the works for more than 7 years, we'd like to emphasize that this component is production ready and battle-tested. Accordingly, we will *promise* to continue our long-term support (LTS) for at least 24 months, so you have a rock-solid foundation to build on top of.

We would like to thank everyone who has contributed to ReactPHP over the years, whether it’s been through code contributions, publishing blog posts and videos, helping with the documentation, answering questions on the issue tracker or chat, or just spreading the word about ReactPHP.

If you're also excited about the future of ReactPHP, you can help us! Working on the next major version still involves a lot of work (join our [discussion](https://github.com/orgs/reactphp/discussions/481)) and we're always looking for sponsors to allow us to spend more time on ReactPHP. Check out [ReactPHP's sponsor profile](https://github.com/sponsors/reactphp) and consider supporting the ongoing development ❤️

It’s been an amazing ride so far and we’re excited to see what the future brings! Happy birthday and here’s to more awesome years of asynchronous PHP with [ReactPHP](https://reactphp.org/)! 🎉
