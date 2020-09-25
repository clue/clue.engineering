---
title: Introducing IPv6 for ReactPHP
tags:
  - introducing-reactphp
  - reactphp
  - release
  - ipv6
author:
  - Christian Lück
---

Today, we're very happy to announce the immediate availability of the next `v1.4.0` feature release of [reactphp/socket](https://github.com/reactphp/socket), the async, streaming plaintext TCP/IP and secure TLS socket server and client for [ReactPHP](https://reactphp.org/). 🎉

As the main feature of this release, this library now has support for IPv6 out of the box.
While previous versions already supported IPv6 when explicitly giving an IPv6 address,
the new version now automatically tries IPv6 connections when connecting using hostnames.
This is a major step to improve connectivity for increasingly common IPv6 setups.

As an example, the following code will create a TCP/IP client side connection, automatically choosing IPv6 or IPv4:

```php
$loop = React\EventLoop\Factory::create();
$connector = new React\Socket\Connector($loop);

$uri = 'tls://gmail.com:443';
$connector->connect($uri)->then(function (React\Socket\ConnectionInterface $connection) {
    echo 'Connected to ' . $connection->getRemoteAddress() . PHP_EOL;
    $connection->write("GET / HTTP/1.0\r\nHost: gmail.com\r\n\r\n");
 
    $connection->on('data', function ($data) {
        echo $data;
    });
}, 'printf');

$loop->run();
```

Significant work has been put into making sure this works with existing setups in the wild,
including hosts that do not provide working IPv6 support.
Internally, we've implemented the [Happy Eyeballs](https://en.wikipedia.org/wiki/Happy_Eyeballs)
algorithm which means we automatically try multiple connection attempts simultaneously over IPv6 and IPv4.
By introducing small delays between each connection attempt and giving a small preference to IPv6,
this means IPv6 will now be used by default in dual-stack hosts.

If either the client or the server side doesn't provide proper IPv6 support,
this will automatically fall back to an IPv4 connection like previous versions.
Likewise, this means you can now connect to (much rarer) IPv6-only hosts.
If for whatever reason your application isn't IPv6 ready yet (for example because you're storing a remote address in a fixed-size database column),
you can explicitly toggle this behavior by changing a new `Connector` option like this:

```php
$connector = new React\Socket\Connector(
    $loop,
    [
        'happy_eyeballs' => false
    ]
);
```

Thanks to ReactPHP's component-based design, we only have to update this one component and can support IPv6 for any existing higher-level implementation with ease,
whether it's a common [HTTP client](https://clue.engineering/2018/introducing-reactphp-buzz) implementation or some obscure binary protocol.
Now, first make sure to update your libraries, head over to [reactphp/socket](https://github.com/reactphp/socket) and let's celebrate this release 🎉

We've spent dozens of hours making sure this feature works across all setups and in all scenarios
and we very much welcome your feedback.
If you care about [sustainable open-source](2019-sustainability-report) (*hint: you should*),
you may also want to keep in mind that given the extensive tests and many revisions,
this turned out to be one of the more *expensive* releases.
Consider [sponsoring me on GitHub](https://github.com/sponsors/clue) if you like to see us keep up with this.
I'd love to hear your feedback, use the contact options in the section below and let's get in touch.
 