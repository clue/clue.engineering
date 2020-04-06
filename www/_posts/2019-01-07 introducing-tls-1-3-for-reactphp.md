---
title: Introducing TLS 1.3 for ReactPHP
legacy_id: 2019/introducing-tls-1-3-for-reactphp
tags:
  - introducing-reactphp
  - reactphp
  - release
  - tls
author:
  - Christian Lück
---

Today, we're very happy to announce the immediate availability of the next `v1.2.0` feature release of [reactphp/socket](https://github.com/reactphp/socket), the async, streaming plaintext TCP/IP and secure TLS socket server and client for [ReactPHP](https://reactphp.org/). 🎉

As the main feature of this release, this library now has improved support for secure TLS 1.3 connections for both server side connections as well as client side connections. TLS 1.3 is an official standard as of August 2018. The protocol has major improvements in the areas of security, performance, and privacy. It is an exciting protocol update that we can expect to benefit from for years to come. Not only will encrypted connections (such as HTTPS) become faster, but they will also be more secure. If you want to learn more about TLS 1.3, see also [CloudFlare's excellent introduction](https://blog.cloudflare.com/introducing-tls-1-3/).

![](https://blog.cloudflare.com/content/images/2018/05/Screen-Shot-2018-05-23-at-8.49.33-AM.png)

As an example, using ReactPHP on a recent system, the following code will create a secure TLS 1.3 client side connection by default:

```php
$loop = React\EventLoop\Factory::create();
$connector = new React\Socket\Connector($loop);

$uri = 'tls://gmail.com:443';
$connector->connect($uri)->then(function (React\Socket\ConnectionInterface $connection) {
    $connection->on('data', function ($data) {
        echo $data;
    });
    $connection->on('close', function () {
        echo '[CLOSED]' . PHP_EOL;
    });

    $connection->write("GET / HTTP/1.0\r\nHost: gmail.com\r\n\r\n");
}, 'printf');

$loop->run();
```

Significant work has been put into making sure TLS 1.3 is compatible with existing implementations in the wild, even including broken TLS 1.2 implementations. Likewise, we (the ReactPHP team) have spent significant effort into making sure TLS 1.3 works out of the box in the ReactPHP ecosystem by default. While closely monitoring PHP's development, this means that at the moment we [work around](https://github.com/reactphp/socket/pull/186) PHP's current lack of [explicit support for TLS 1.3](https://github.com/php/php-src/pull/3700). Despite having a working solution, we will continue monitoring and supporting this upstream development to provide a longer-term solution for the whole ecosystem.

Note that TLS 1.3 is an official standard as of August 2018. TLS 1.3 is only supported by default as of [OpenSSL 1.1.1](https://www.openssl.org/blog/blog/2018/09/11/release111/). For example, this version ships with Ubuntu 18.10 (and newer) by default, meaning that recent installations support TLS 1.3 out of the box :shipit:

If you're using an older version of OpenSSL, then this component and the above example will continue to use TLS 1.2 by default. Likewise, if the remote server side has not been updated to support TLS 1.3, this example will automatically fall back to TLS 1.2 by default. In other news, *now* is a good time to upgrade to the latest versions.

Thanks to ReactPHP's component-based design, we only have to update this one component and can support TLS 1.3 for any existing higher-level implementation with ease, whether it's a common [HTTP(S) client](https://clue.engineering/2018/introducing-reactphp-buzz) implementation or some obscure binary protocol. Now, first make sure to update your libraries, head over to [reactphp/socket](https://github.com/reactphp/socket) and let's celebrate this release 🎉

If you have any feedback or just want to reach out and say hello, I'm happy to hear back and appreciate feedback! Use the comment section below or send a tweet to [@another_clue](https://twitter.com/another_clue).

<blockquote class="twitter-tweet" data-lang="de"><p lang="en" dir="ltr">TLS 1.3 for <a href="https://twitter.com/reactphp?ref_src=twsrc%5Etfw">@ReactPHP</a> is exciting news! 🎉 The protocol has major  improvements in the areas of security, performance, and privacy. Also  wrote a short blog post announcing this 🐘💪 <a href="https://twitter.com/hashtag/php?src=hash&amp;ref_src=twsrc%5Etfw">#php</a> <a href="https://twitter.com/hashtag/tls13?src=hash&amp;ref_src=twsrc%5Etfw">#tls13</a> <a href="https://t.co/5I7FhpFKXH">https://t.co/5I7FhpFKXH</a></p>&mdash; Christian Lück (@another_clue) <a href="https://twitter.com/another_clue/status/1082316633778081797?ref_src=twsrc%5Etfw">7. Januar 2019</a></blockquote>
