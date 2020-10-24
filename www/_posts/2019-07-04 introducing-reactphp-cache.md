---
title: Introducing async cache for ReactPHP
tags:
  - introducing-reactphp
  - reactphp
  - release
  - cache
author:
  - Christian Lück
---

Today, we're very happy to announce the immediate availability of the next major beta release of [reactphp/cache](https://github.com/reactphp/cache), the async cache library for [ReactPHP](https://reactphp.org/). 🎉

**ReactPHP ❤️ PSRs**

As the main feature of this `v0.6.0` release, this library now provides an updated [`CacheInterface`](https://github.com/reactphp/cache#cacheinterface) that provides all the common methods that consumers would expect from an async cache, including methods to work with multiple cache items at once. This project is heavily inspired by the great [PSR-16: Common Interface for Caching Libraries](https://www.php-fig.org/psr/psr-16/), but uses an interface more suited for async, non-blocking applications.

This post aims more for the "why" instead of "what" has changed. This release involves a few minor BC breaks, but we expect that most consumers of this package will actually not be affected. If you're upgrading from a previous version of this project, you may want to take a look at the [changelog](https://github.com/reactphp/cache/releases/tag/v0.6.0) describing the changes in greater detail. On top of this, we're planning to not introduce any other BC changes in the foreseeable future and provide stable, LTS support for this project very soon. Alright, so let's dive right in.

## Caching 101

> Caching is a common way to improve the performance of any project, making caching libraries one of the most common features of many frameworks and libraries. Interoperability at this level means libraries can drop their own caching implementations and easily rely on the one given to them by the framework, or another dedicated cache library. – [PSR-16 introduction](https://www.php-fig.org/psr/psr-16/#11-introduction)

A common use case of caches is to attempt fetching a cached value and as a fallback retrieve it from the original data source if not found. Here is an example of that:

```
$cache
    ->get('foo')
    ->then(function ($result) {
        if ($result === null) {
            return getFooFromDb();
        }

        return $result;
    })
    ->then('var_dump');
```

## Cache Adapters

This project already contains a simple [`ArrayCache`](https://github.com/reactphp/cache#arraycache) implementations which can be used as an efficient and lightweight in-memory cache. [ReactPHP's ecosystem](https://github.com/reactphp/react/wiki/Users#cache-implementations) already provides a number of cache adapter implementations for common caching systems, including [Redis](https://github.com/wyrihaximus/reactphp-cache-redis), [Memcached](https://github.com/seregazhuk/php-react-cache-memcached) and the local [filesystem](https://github.com/wyrihaximus/reactphp-cache-filesystem). This means that no matter your use case, we've got you covered and already support many of the common cache systems.

> Note that at the time of writing this, the last tag is just over an hour old and these projects may still require an update to support the added APIs. I will update this post in the future once they've had a chance to catch up.

Do you feel some implementation for your favorite cache system is missing? Check out [@zhukserega](https://twitter.com/zhukserega)'s excellent [blog series](https://sergeyzhuk.me/2017/10/09/memcached-reactphp-p1/) to build your own cache implementation and make sure to share it with the world!

## Conclusions

Caching is a common way to improve the performance of any project. The Cache component allows you to easily add async caching support to any higher level implementation taking advantage of it. On top of this, even if your higher-level domain use case does not require caching, you will probably appreciate that the Cache component can be used to avoid many of the lower-level network operations, like avoiding HTTP requests or DNS lookups. In fact, the Cache component already has [4+ Mio installations](https://packagist.org/packages/react/cache/stats) because if you've ever installed any ReactPHP component, you will most likely already use the Cache component under the hood and can avoid many repetitive [DNS lookups](https://github.com/reactphp/dns#caching).

We're looking forward to ensuring this API is useful for as many projects as possible. That's why we're planning to make sure this API will get a stable, LTS release very soon. If you want to learn more about this project, make sure to head over to [reactphp/cache](https://github.com/reactphp/cache) and make sure to let us know what you think about this! ❤️ Let's celebrate this release 🎉

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">We&#39;re happy to announce the next major v0.6.0 release of react/cache, the async cache library for <a href="https://twitter.com/reactphp?ref_src=twsrc%5Etfw">@ReactPHP</a>! 🎉 Stable LTS following very soon! 😉💪<a href="https://t.co/XKSkvpHreM">https://t.co/XKSkvpHreM</a></p>&mdash; Christian Lück (@another_clue) <a href="https://twitter.com/another_clue/status/1146835031974907904?ref_src=twsrc%5Etfw">July 4, 2019</a></blockquote>
