---
title: Introducing SSH proxy connector for ReactPHP
legacy_id: https://www.lueck.tv/2018/introducing-reactphp-ssh-proxy
tags:
  - introducing-reactphp
  - reactphp
  - release
  - ssh
  - proxy
---

Today, I'm happy to announce the very first stable `v1.0.0` release of [clue/reactphp-ssh-proxy](https://github.com/clue/reactphp-ssh-proxy),
the async SSH proxy connector and forwarder, tunnel any TCP/IP-based protocol through an SSH server, built on top of [ReactPHP](https://reactphp.org/). 🎉

Now that v1.0.0 has been tagged and released today, let's take a look at how we can use SSH tunnels as a powerful feature for many different use cases, how it compares to other proxy protocols and why I think ReactPHP's design makes it a perfect fit.

## SSH proxy a.k.a. SSH tunnel

[Secure Shell (SSH)](https://en.wikipedia.org/wiki/Secure_Shell) is a secure network protocol that is most commonly used to access a login shell on a remote server. Its architecture allows it to use multiple secure channels over a single connection. Among others, this can also be used to create an "SSH tunnel", which is commonly used to tunnel HTTP(S) traffic through an intermediary ("proxy"), to conceal the origin address (anonymity) or to circumvent address blocking (geoblocking). This can be used to tunnel any TCP/IP-based protocol (HTTP, SMTP, IMAP etc.) and as such also allows you to access local services that are otherwise not accessible from the outside (database behind firewall).

[clue/reactphp-ssh-proxy](https://github.com/clue/reactphp-ssh-proxy) is implemented as a lightweight process wrapper around the `ssh` client binary and provides a simple API to create these tunneled connections for you. Because it implements ReactPHP's standard [`ConnectorInterface`](https://github.com/reactphp/socket#connectorinterface), it can simply be used in place of a normal connector. This makes it fairly simple to add SSH proxy support to pretty much any existing higher-level protocol implementation.

## Proxy HTTP requests

> I'm probably not telling you something new when I say the web is built on top of HTTP. This blog post is served over HTTP. Your YouTube videos are served over HTTP. Your downloads are served over HTTP. RESTful backend APIs are served over HTTP. GraphQL APIs are served over HTTP. SOAP APIs are served over HTTP. Yes, I may be oversimplifying things a bit here, but I think you get the point.
>
> – From my recent blog post [introducing async HTTP requests with ReactPHP](https://clue.engineering/2018/introducing-reactphp-buzz).

Yes, I've [mentioned this before](https://clue.engineering/2018/introducing-reactphp-http-proxy) [multiple times](https://clue.engineering/2018/introducing-reactphp-socks) and I will mention it again: With HTTP being so ubiquitous, it's no surprise that using a proxy server for HTTP requests is one of the more common requirements when using proxy servers. To recap once again, let's first take a look at how to send an HTTP request with ReactPHP, again from the [recent blog post](https://clue.engineering/2018/introducing-reactphp-buzz):

```php
$loop = React\EventLoop\Factory::create();
$client = new Clue\React\Buzz\Browser($loop);

$client->get('https://api.example.com/')->then(function (ResponseInterface $response) {
    var_dump($response->getHeaders(), (string)$response->getBody());
});

$loop->run();
```

This example makes no mention of any proxy setup and thus sends a `GET` request over a direct connection to the destination host. If you want to proxy the same HTTP request through an SSH proxy server, you only have to add a few extra lines of code. If you remember the recent blog post [introducing HTTP CONNECT proxy support](https://clue.engineering/2018/introducing-reactphp-http-proxy) or [introducing SOCKS proxy support](https://clue.engineering/2018/introducing-reactphp-socks), the following should be no surprise. After installing the SSH proxy support with `composer require clue/reactphp-ssh-proxy:^1.0`, the same example could look something like this:

```php
$loop = React\EventLoop\Factory::create();

$proxy = new Clue\React\SshProxy\SshSocksConnector('user@example.com', $loop);
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

For this to work, you'll just need to have SSH access as `user@example.com` and be allowed to use port forwarding (which is the default for most distributions). If you already have a server or VPS running somewhere and have ever used any SSH client to access it, there's a fair chance you can simply pass in your credentials in the previous example and start using it as a proxy server right away! The gist: If you can access a remote SSH server with `ssh user@example.com`, then so can this project.

Now what does all of this code mean? Admittedly, the few extra lines of code added near the top may look a bit confusing at first, so let's ignore this for a moment. Interestingly, what has *not* changed is any of the code that actually sends the HTTP requests. In fact, if you go take a look at the internals of this [HTTP client](https://github.com/clue/reactphp-buzz), you'll find that all of this works without having even a single line of code internally dedicated to proxy server support.

Now what does this code actually do? The few extra lines of code added near the top specifically change the way the HTTP client creates a connection to the destination host. Instead of using the default `Connector` to create a direct connection to the host, we create an explicit `Connector` which uses the proxy server to create the connection to the destination host. What this means is that the HTTP client doesn't really require any changes, it only requires a special `Connector` which somehow creates this connection to the destination. What the `SshSocksConnector` does internally, is it creates a connection to the proxy server though the `ssh` client binary, uses the SOCKS proxy protocol to ask the local SSH client to create a connection to the destination host and then returns this connection once it's ready. Remember that if you can access a remote SSH server with `ssh user@example.com`, then so can this project? In fact, this project will simply spawn the `ssh` client binary with the equivalent of `ssh -D 1080 user@example.com` and then monitor and use this running process. You can open any number of connections over this one process and once the last connection closes, it will automatically kill this process again, freeing any resources allocated.

## Tunnel any protocol!

In the previous chapter we've seen how this project can be used to send HTTP requests through an SSH proxy server. Likewise, we can use this to tunnel any tool/protocol that builds on top of HTTP over an SSH proxy server, whether it's your favorite RESTful HTTP API, GraphQL API or even [SOAP](https://clue.engineering/2018/introducing-reactphp-soap).

But what about other protocols? If you look closely at the previous example, you'll see that nothing of what we've discussed so far is really limited to HTTP at all. In fact, if you look a bit closer at the previous example, you'll see that it already uses HTTPS (secure HTTP over TLS) instead of plain HTTP. What this means is that SSH proxy servers do not really care what kind of (payload) protocol you send over this tunneled connection, so this can be used to tunnel any TCP/IP-based protocol (HTTP, SMTP, IMAP etc.).

[ReactPHP's vast ecosystem](https://github.com/reactphp/react/wiki/Users) features a large number of existing client implementations for pretty much any widespread protocol and database system out there. Any project that builds on top of ReactPHP's components will in one way or another use a `Connector` to create its underlying connection to its destination host. Accordingly, if you go take a look at their documentation, you'll find that pretty much all of them expose an optional `Connector` instance somehow. Among others, this allows us to pass an explicit proxy connector like in the previous example. For example, this allows us to create a MySQL or Redis database connection over an SSH proxy server.

## Tunneled database connections

We should now have a basic understanding of how we can tunnel any TCP/IP-based protocol over an SSH proxy server. Besides using this to access "external" services, this is also particularly useful because it allows you to access network services otherwise only local to this SSH server from the outside, such as a firewalled database server.

For example, taking the [lazy MySQL database connections](https://clue.engineering/2018/introducing-reactphp-mysql-lazy-connections) from a previous blog post and combining it with the above SSH proxy server setup, you can access a firewalled MySQL database server through an SSH tunnel. Here's the gist:

```php
$loop = React\EventLoop\Factory::create();

$proxy = new Clue\React\SshProxy\SshProcessConnector('user@example.com', $loop);
$connector = new React\Socket\Connector($loop, array(
    'tcp' => $proxy,
    'dns' => false
));

$uri = 'test:test@localhost/test';
$factory = new React\MySQL\Factory($loop, $connector);
$connection = $factory->createLazyConnection($uri);

$connection->query('SELECT * FROM book')->then(
    function (QueryResult $command) {
        echo count($command->resultRows) . ' row(s) in set' . PHP_EOL;
    },
    function (Exception $error) {
        echo 'Error: ' . $error->getMessage() . PHP_EOL;
    }
);

$connection->quit();

$loop->run();
```

This example will automatically launch the `ssh` client binary to create the connection to a database server that can not otherwise be accessed from the outside. From the perspective of the database server, this looks just like a regular, local connection. From this code's perspective, this will create a regular, local connection which just happens to use a secure SSH tunnel to transport this to a remote server, so you can send any query like you would to a local database server.

## Conclusions

[Secure Shell (SSH)](https://en.wikipedia.org/wiki/Secure_Shell) is a secure network protocol that can also be used to create an "SSH tunnel", which is commonly used to tunnel HTTP(S) traffic through an intermediary ("proxy"), to conceal the origin address (anonymity) or to circumvent address blocking (geoblocking). This can be used to tunnel any TCP/IP-based protocol (HTTP, SMTP, IMAP etc.) and also allows you to access local services that are otherwise not accessible from the outside (database behind firewall). Thanks to ReactPHP's component-based design, we can add SSH proxy server support to pretty much any existing higher-level implementation with ease, whether it's a common HTTP client implementation or some obscure binary protocol.

If you want to learn more about this project, make sure to check out the project homepage of [clue/reactphp-ssh-proxy](https://github.com/clue/reactphp-ssh-proxy). Its documentation describes common usage patterns as well as all the nifty details. While it is a relatively new project, it is considered stable and you're invited to also give it a try! If you like this project, spreading the word is much appreciated! If you have any feedback or just want to reach out and say hello, I'm happy to hear back and appreciate feedback! Use the comment section below or send a tweet to [@another_clue](https://twitter.com/another_clue).

<blockquote class="twitter-tweet" data-lang="de"><p lang="en" dir="ltr">Just released clue/reactphp-ssh-proxy v1.0.0! 🎉 Tunnel any TCP/IP-based protocol over an automatic SSH tunnel with plain PHP and access your firewalled database on a remote server as if it&#39;s local with <a href="https://twitter.com/reactphp?ref_src=twsrc%5Etfw">@ReactPHP</a>. 🐘💪 <a href="https://twitter.com/hashtag/async?src=hash&amp;ref_src=twsrc%5Etfw">#async</a> <a href="https://twitter.com/hashtag/php?src=hash&amp;ref_src=twsrc%5Etfw">#php</a> <a href="https://twitter.com/hashtag/ssh?src=hash&amp;ref_src=twsrc%5Etfw">#ssh</a> <a href="https://t.co/STVCGbGxXu">https://t.co/STVCGbGxXu</a></p>&mdash; Christian Lück (@another_clue) <a href="https://twitter.com/another_clue/status/1075486829703557122?ref_src=twsrc%5Etfw">19. Dezember 2018</a></blockquote>
