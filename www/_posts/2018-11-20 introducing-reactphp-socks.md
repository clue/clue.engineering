---
title: Introducing SOCKS proxy connector for ReactPHP
tags:
  - introducing-reactphp
  - reactphp
  - release
  - socks
  - proxy
---

Today, I'm happy to announce the `v1.0.0` release of [clue/reactphp-socks](https://github.com/clue/reactphp-socks),
the async SOCKS proxy connector client and server implementation, tunnel any TCP/IP-based protocol through a SOCKS5 or SOCKS4(a) proxy server, built on top of [ReactPHP](https://reactphp.org/). 🎉

Don't be fooled by the version number: Its [release history](https://github.com/clue/reactphp-socks/releases) suggests this is not exactly a new project. In fact, this is the first project that got me started with ReactPHP around six years ago (*time flies by*) and has been used in production in a number of projects ever since. So I guess it's about time to write an introductory blog post about this project, what SOCKS proxy servers can be used for and why I think ReactPHP's design makes it a perfect fit.

## Pull your SOCKS up

The SOCKS proxy protocol family (SOCKS5, SOCKS4 and SOCKS4a) is commonly used to tunnel HTTP(S) traffic through an intermediary ("proxy"), to conceal the origin address (anonymity) or to circumvent address blocking (geoblocking). While many (public) SOCKS proxy servers often limit this to HTTP(S) port 80 and 443 only, this can technically be used to tunnel any TCP/IP-based protocol (HTTP, SMTP, IMAP etc.).

[clue/reactphp-socks](https://github.com/clue/reactphp-socks) provides a simple API to create these tunneled connections for you. Because it implements ReactPHP's standard `ConnectorInterface`, it can simply be used in place of a normal connector. This makes it fairly simple to add SOCKS proxy support to pretty much any existing higher-level protocol implementation. Besides the client side, it also provides a simple SOCKS server implementation which allows you to build your own SOCKS proxy servers with custom business logic. But first, let's start with taking a look at one of the most common use cases for using SOCKS proxy servers in PHP...

## Proxy HTTP requests

> I'm probably not telling you something new when I say the web is built on top of HTTP. This blog post is served over HTTP. Your YouTube videos are served over HTTP. Your downloads are served over HTTP. RESTful backend APIs are served over HTTP. GraphQL APIs are served over HTTP. SOAP APIs are served over HTTP. Yes, I may be oversimplifying things a bit here, but I think you get the point.
>
> – From my recent blog post [introducing async HTTP requests with ReactPHP](https://clue.engineering/2018/introducing-reactphp-buzz).

Yes, I've [mentioned this before](https://clue.engineering/2018/introducing-reactphp-http-proxy) and I will mention it again: With HTTP being so ubiquitous, it's no surprise that using a proxy server for HTTP requests is one of the more common requirements when using proxy servers. To recap once again, let's first take a look at how to send an HTTP request with ReactPHP, again from the [recent blog post](https://clue.engineering/2018/introducing-reactphp-buzz):

```php
$loop = React\EventLoop\Factory::create();
$client = new Clue\React\Buzz\Browser($loop);

$client->get('https://api.example.com/')->then(function (ResponseInterface $response) {
    var_dump($response->getHeaders(), (string)$response->getBody());
});

$loop->run();
```

This example makes no mention of any proxy setup and thus sends a `GET` request over a direct connection to the destination host. If you want to proxy the same HTTP request through a SOCKS proxy server, you only have to add a few extra lines of code. If you remember the recent blog post [introducing HTTP CONNECT proxy support](https://clue.engineering/2018/introducing-reactphp-http-proxy), the following should be no surprise. After installing the SOCKS proxy support with `composer require clue/socks-react:^1.0`, the same example could look something like this:

```php
$loop = React\EventLoop\Factory::create();

$proxy = new Clue\React\Socks\Client('socks://127.0.0.1:8080', new React\Socket\Connector($loop));
$connector = new React\Socket\Connector($loop, array(
    'tcp' => $proxy,
    'dns' => false
));

$client = new Clue\React\Buzz\Browser($loop, $connector);

$client->get('https://api.example.com/')->then(function (ResponseInterface $response) {
    var_dump($response->getHeaders(), (string)$response->getBody());
});

$loop->run();
```

For this to work, you'll need to have a proxy server listening on `127.0.0.1:8080`. We'll get back to this in moment, so for now let's just assume you're already running a proxy server on this address or simply adjust this example to use an appropriate proxy address for your particular setup.

Now what does all of this code mean? Admittedly, the few extra lines of code added near the top may look a bit confusing at first, so let's ignore this for a moment as well. Interestingly, what has *not* changed is any of the code that actually sends the HTTP requests. In fact, if you go take a look at the internals of this [HTTP client](https://github.com/clue/reactphp-buzz), you'll find that all of this works without having even a single line of code internally dedicated to proxy server support.

Now what does this code actually do? The few extra lines of code added near the top specifically change the way the HTTP client creates a connection to the destination host. Instead of using the default `Connector` to create a direct connection to the host, we create an explicit `Connector` which uses the proxy server to create the connection to the destination host. What this means is that the HTTP client doesn't really require any changes, it only requires a special `Connector` which somehow creates this connection to the destination. What the `Client` does internally, is it creates a connection to the proxy server, uses the SOCKS proxy protocol to ask the proxy to create a connection to the destination host and then returns this connection once it's ready.

## Tunnel any protocol!

In the previous chapter we've seen how this project can be used to send HTTP requests through a SOCKS proxy server. Likewise, we can use this to tunnel any tool/protocol that builds on top of HTTP over a SOCKS proxy server, whether it's your favorite RESTful HTTP API, GraphQL API or even [SOAP](https://clue.engineering/2018/introducing-reactphp-soap).

But what about other protocols? If you look closely at the previous example, you'll see that nothing of what we've discussed so far is really limited to HTTP at all. In fact, if you look a bit closer at the previous example, you'll see that it already uses HTTPS (secure HTTP over TLS) instead of plain HTTP. What this means is that SOCKS proxy servers do not really care what kind of (payload) protocol you send over this tunneled connection. While many (public) SOCKS proxy servers often limit this to HTTP(S) port `80` and `443` only, this can technically be used to tunnel any TCP/IP-based protocol (HTTP, SMTP, IMAP etc.).

[ReactPHP's vast ecosystem](https://github.com/reactphp/react/wiki/Users) features a large number of existing client implementations for pretty much any widespread protocol and database system out there. Any project that builds on top of ReactPHP's components will in one way or another use a `Connector` to create its underlying connection to its destination host. Accordingly, if you go take a look at their documentation, you'll find that pretty much all of them expose an optional `Connector` instance somehow. Among others, this allows us to pass an explicit proxy connector like in the previous example. For example, this allows us to create a MySQL or Redis database connection over a SOCKS proxy server.

## SOCKS proxy servers

We should now have a basic understanding of how we can tunnel any TCP/IP-based protocol over a SOCKS proxy server. Obviously, for this to work, you'll need to have a proxy server running somewhere. If you're not already running a proxy server, you can simply download and run [LeProxy](https://leproxy.org) (no installation or configuration required). As an alternative, you can also use your favorite search engine to search for free SOCKS proxy servers (which are often of mixed quality) or use your favorite paid proxy subscription plan and adjust the previous example to use the appropriate proxy address.

How you want your proxy servers set up and which of the above works best for your use case depends on your particular requirements. Fortunately, with SOCKS being a relatively wide-spread protocol, it is also very well-supported for many common setups. In particular, did you know that you can simply [use any SSH server as a SOCKS proxy server](https://github.com/clue/reactphp-socks#using-ssh-as-a-socks-server)? For example, you can simply direct your SSH client to start a local SOCKS proxy server like this:

```bash
$ ssh -D 1080 chris@example.com
```

Now you can simply use this local SSH SOCKS server in the previous example. This is particularly interesting because it allows you to access network services otherwise only local to this SSH server from the outside, such as a firewalled database server. Again, I'm barely touching the surface here of why I think this such a powerful feature, but I'll try to keep this blog post short(er) and leave this up for another post soon-ish. Likewise, we can also use [Tor (anonymity network) to tunnel SOCKS connections](https://github.com/clue/reactphp-socks#using-the-tor-anonymity-network-to-tunnel-socks-connections) or even use this project to build our own SOCKS server with custom business logic in pure PHP...

## Conclusions

SOCKS proxy servers are commonly used to tunnel HTTPS traffic through an intermediary ("proxy"), to conceal the origin address (anonymity) or to circumvent address blocking (geoblocking). Likewise, we can use this to tunnel any TCP/IP-based protocol. Thanks to ReactPHP's component-based design, we can add SOCKS proxy server support to pretty much any existing higher-level implementation with ease, whether it's a common HTTP client implementation or some obscure binary protocol.

If you want to learn more about this project, make sure to check out the project homepage of [clue/reactphp-socks](https://github.com/clue/reactphp-socks). Its documentation describes common usage patterns as well as all the nifty details. It is considered stable and feature complete and has been used in production for a number of years already, so you're invited to also give it a try! If you like this project, spreading the word is much appreciated! If you have any feedback or just want to reach out and say hello, I'm happy to hear back and appreciate feedback! Use the comment section below or send a tweet to [@another_clue](https://twitter.com/another_clue).

<blockquote class="twitter-tweet" data-lang="de"><p lang="en" dir="ltr">Just released clue/reactphp-socks v1.0.0! 🎉 This will blow your SOCKS off (sorry)! It allows you to tunnel any TCP/IP-based protocol over a SOCKS proxy server with plain PHP. Efficiently process large number of HTTP requests with <a href="https://twitter.com/reactphp?ref_src=twsrc%5Etfw">@ReactPHP</a>. <a href="https://twitter.com/hashtag/async?src=hash&amp;ref_src=twsrc%5Etfw">#async</a> <a href="https://twitter.com/hashtag/php?src=hash&amp;ref_src=twsrc%5Etfw">#php</a> <a href="https://t.co/jJ1p3YJ8T0">https://t.co/jJ1p3YJ8T0</a></p>&mdash; Christian Lück (@another_clue) <a href="https://twitter.com/another_clue/status/1064906777190383618?ref_src=twsrc%5Etfw">20. November 2018</a></blockquote>
