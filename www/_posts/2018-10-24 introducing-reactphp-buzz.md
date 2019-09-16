---
title: Introducing async HTTP requests with ReactPHP
---

Today, I'm happy to announce the `v2.5.0` release of [clue/reactphp-buzz](https://github.com/clue/reactphp-buzz) 🎉

> Simple, async PSR-7 HTTP client for concurrently processing any number of HTTP requests, built on top of [ReactPHP](https://reactphp.org/).

As the version number suggests, this is not exactly a new project. In fact, this has been used in production in a larger number of projects for a few years already. So I guess it's about time to write an introductory blog post about this project, why async HTTP requests are such a powerful feature and also a bit about the motivation for this project and why I think @ReactPHP is a perfect fit for sending HTTP requests.

## HTTP all the things!

I'm probably not telling you something new when I say the web is built on top of HTTP. This blog post is served over HTTP. Your YouTube videos are served over HTTP. Your downloads are served over HTTP. RESTful backend APIs are served over HTTP. GraphQL APIs are served over HTTP. SOAP APIs are served over HTTP. Yes, I may be oversimplifying things a bit here, but I think you get the point.

With HTTP being so ubiquitous, I'm happy to let you know that using it with @ReactPHP is just a few lines of code away:

```php
$loop = \React\EventLoop\Factory::create();
$client = new \Clue\React\Buzz\Browser($loop);

$client->get('https://api.example.com/')->then(function (ResponseInterface $response) {
    var_dump($response->getHeaders(), (string)$response->getBody());
});

$loop->run();
```

Now if you're entirely new to this project, I should probably mention that you have to install it first (Who would have guessed that?). A single `composer require clue/buzz-react:^2.5` command does this for you.

If you've never worked with @ReactPHP and async APIs in PHP before, the `$loop` boilerplate around the middle part may look a bit strange to you, so let's ignore this for a moment. Other than that, if you've ever worked with Guzzle or Buzz or pretty much any other HTTP client in PHP, it should be pretty obvious that the `get()` method sends a `GET` request and this code will simply dump all HTTP response headers and the full HTTP response body to the output. Because all these projects use [PSR-7](https://www.php-fig.org/psr/psr-7/) interfaces to represent HTTP messages, there's a fair chance you might be familiar with this piece of code already. For comparision, let's take a look at the same example with Guzzle:

```php
$client = new \GuzzleHttp\Client();

$response = $client->get('https://api.example.com/');
var_dump($response->getHeaders(), (string)$response->getBody());
```

## Concurrent HTTP requests

If we only ever send a single HTTP request, both examples above will do pretty much the same thing and it would be hard to argue that either example is "better". Now again with HTTP being so ubiquitous, there's a fair chance we will have to issue more than one request in our application, so let's take a look at that:

```php
$loop = \React\EventLoop\Factory::create();
$client = new \Clue\React\Buzz\Browser($loop);

$client->get('https://api.example.com/users/alice')->then(function (ResponseInterface $response) {
    var_dump($response->getHeaders(), (string)$response->getBody());
});

$client->get('https://api.example.com/users/bob')->then(function (ResponseInterface $response) {
    var_dump($response->getHeaders(), (string)$response->getBody());
});

$loop->run();
```

It should be no surprise that this example will send two independent `GET` requests and will again dump their responses. What is worth noting, however, is how this is executed. Being entirely async, this piece of code will actually send two requests *concurrently*.

**1 + 1 = 1?**

What this means, in a gist, is that if a single request takes 1 second to complete, then two requests will also take just 1 second (assuming ideal network conditions). By leveraging non-blocking I/O, actually sending the HTTP request over the wire and receiving the HTTP response takes close to zero seconds. Most of the time will only be spend *waiting* for the remote server to actually serve the request. This is not just some theoretical construct, but something that bears some very real real-world performance improvements.

Depending mostly on what kind of load the receiving side is willing to accept, this approach scales very well to around a dozen or so concurrent requests. If you want to send a larger number of requests, you may want to take a look at one of the previous blog posts introducing an [in-memory queue](https://clue.engineering/2018/introducing-reactphp-mini-queue) or [managing flux](https://clue.engineering/2018/introducing-reactphp-flux) to throttle your sending side to limit concurrency to whatever limit works best for your specific use case.

## Conclusions

HTTP is everywhere. This makes [clue/reactphp-buzz](https://github.com/clue/reactphp-buzz) an important piece of the puzzle of bringing @ReactPHP to the masses. It features some very efficient code to process a large number of requests for a large number of different use-cases. Among others, it can be used for [scaping the web](https://sergeyzhuk.me/2018/02/12/fast-webscraping-with-reactphp/), [throttling requests](https://sergeyzhuk.me/2018/03/19/fast-webscraping-with-reactphp-limiting-requests/) or [using proxy servers](https://sergeyzhuk.me/2018/06/20/fast-webscraping-with-reactphp-proxy/). A non-trivial amount of effort is spent on ensuring its APIs are well thought out and well documented. Again, this post is barely touching the surface of all the features and how this can be used, but I'll leave this up for another post soon-ish.

If you want to learn more about this project, make sure to check out the project homepage of [clue/reactphp-buzz](https://github.com/clue/reactphp-buzz). It should provide most of the features you would expect from an HTTP client in PHP (authentication, redirects, timeouts, custom headers, proxy server support etc.). If you like this project, spreading the word is much appreciated! If you have any feedback or just want to reach out and say hello, I'm happy to hear back and appreciate feedback! Use the comment section below or send a tweet to [@another_clue](https://twitter.com/another_clue).

<blockquote class="twitter-tweet" data-lang="de"><p lang="en" dir="ltr">Just released clue/reactphp-buzz v2.5.0! 🎉 It features everything you would expect from an async HTTP client in PHP, including timeout support and revamped documentation! Efficiently process large number of HTTP requests with @ReactpPHP. <a href="https://twitter.com/hashtag/async?src=hash&amp;ref_src=twsrc%5Etfw">#async</a> <a href="https://twitter.com/hashtag/php?src=hash&amp;ref_src=twsrc%5Etfw">#php</a> <a href="https://t.co/WpvciAVJxC">https://t.co/WpvciAVJxC</a></p>&mdash; Christian Lück (@another_clue) <a href="https://twitter.com/another_clue/status/1055162680208773121?ref_src=twsrc%5Etfw">24. Oktober 2018</a></blockquote>
