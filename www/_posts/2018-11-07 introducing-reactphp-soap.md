---
title: Introducing async SOAP requests with ReactPHP
---

Today, I'm happy to announce the `v1.0.0` release of [clue/reactphp-soap](https://github.com/clue/reactphp-soap) 🎉

> Simple, async [SOAP](https://en.wikipedia.org/wiki/SOAP) web service client library, built on top of [ReactPHP](https://reactphp.org/).

To answer the first thing you may be wondering: *Yes, it is 2018* and indeed, this project has been used in production in a number of projects for a few of years already. So I guess it's about time to write an introductory blog post about this project, how SOAP requests can be used and why I think @ReactPHP's design makes it a perfect fit. Warning, terrible puns ahead.

## SOAP shouldn't make you feel dirty

Most notably, SOAP is often used for invoking [Remote procedure calls](https://en.wikipedia.org/wiki/Remote_procedure_call) (RPCs) in distributed systems. Internally, SOAP messages are encoded as XML and usually sent via HTTP POST requests. Each SOAP web service may offer any number of RPC functions. These are usually defined in a public [WSDL](https://en.wikipedia.org/wiki/Web_Services_Description_Language) file which contains definitions for all functions, their arguments and return values. For the most part, SOAP (originally *Simple Object Access protocol*) is a protocol of the past, and in fact anything but *simple*. It is still in use by many (often *legacy*) systems.

Nowadays, competing approaches could involve (RESTful) HTTP APIs, GraphQL and JSON-RPC, among others. I'm not going to argue that either approach would be best suited for your particular use-case, but I *will* argue that many SOAP APIs have clearly stood the test of time and continue to provide very real business value with little maintenance overhead. This remains something  the more modern approaches to API design have yet to prove. Arguably, while RPCs formatted as XML sent over HTTP are not exactly network-efficient, this is not really a major concern for many of the more *enterprisey* applications out there.

## Async SOAP requests

Using SOAP with PHP is relatively straight-forward: Its [`SoapClient`](http://php.net/manual/en/soapclient.soapclient.php) provides everything you need on the client (calling) side. You can simply point this class to the URL of the WSDL file of your particular web service and can start calling functions right away. It takes care of marshalling (encoding) your function arguments to a SOAP message as defined in the WSDL file, sending it as an HTTP request, waiting for the response and unmarshalling (parsing) the SOAP response message and exposing the (parsed) return value.

While marshalling to XML and unmarshalling from XML may sound like a complex task, this is something that usually takes no more than a few microseconds. Sending HTTP requests is something that does take significantly more time, usually somewhere in the range of some hundred milliseconds to a few seconds. Fortunately, this is something that can easily be [performed asynchronously](https://clue.engineering/2018/introducing-reactphp-buzz).

This is where [clue/reactphp-soap](https://github.com/clue/reactphp-soap) comes into play: By leveraging PHP's existing [`SoapClient`](http://php.net/manual/en/soapclient.soapclient.php) for (un)marshalling and combining it with the async HTTP client [clue/reactphp-buzz](https://github.com/clue/reactphp-buzz), we can provide a simple API to perform async SOAP requests. Without further ado, let's take a look at an example sending two concurrent SOAP requests:

```php
$loop = \React\EventLoop\Factory::create();
$browser = new \Clue\React\Buzz\Browser($loop);
$wsdl = file_get_contents('service.wsdl');
$client = new \Clue\React\Soap\Client($browser, $wsdl);
$proxy = new \Clue\React\Soap\Proxy($client);

$proxy->demo(1, 2)->then(function ($result) {
    var_dump('first result', $result);
});

$proxy->demo(3, 4)->then(function ($result) {
    var_dump('second result', $result);
});

$loop->run();
```

Now what does all of this code mean? If you remember one of the [previous blog posts](https://clue.engineering/2018/introducing-reactphp-buzz) you'll see some familiar boilerplate. Admittedly, if you've never worked with @reactphp and async APIs in PHP before, the `$loop` boilerplate near the top may look a bit confusing at first, so let's ignore this for a moment.

If we focus on the `$proxy` part, we can see that this example will execute two method calls. These are our RPCs that will transparently be sent to the remote web service and allow us to react to the results of these calls, in this case dumping their results. What is worth noting, however, is how this is executed. Being entirely async, this piece of code will actually send two requests *concurrently*.

> **1 + 1 = 1?**
>
> What this means, in a gist, is that if a single request takes 1 second to complete, then two requests will also take just 1 second (assuming ideal network conditions). By leveraging non-blocking I/O, actually sending the HTTP request over the wire and receiving the HTTP response takes close to zero seconds. Most of the time will only be spend *waiting* for the remote server to actually serve the request. This is not just some theoretical construct, but something that bears some very real real-world performance improvements.
>
> Depending mostly on what kind of load the receiving side is willing to accept, this approach scales very well to around a dozen or so concurrent requests. If you want to send a larger number of requests, you may want to take a look at one of the previous blog posts introducing an [in-memory queue](https://clue.engineering/2018/introducing-reactphp-mini-queue) or [managing flux](https://clue.engineering/2018/introducing-reactphp-flux) to throttle your sending side to limit concurrency to whatever limit works best for your specific use case.
>
> – déjà vu from previous blog post [introducing async HTTP requests](https://clue.engineering/2018/introducing-reactphp-buzz)

## Conclusions

I think we can all agree that soap exists for good reasons (*sorry*). SOAP may not be new and may not be pretty, but it's far from being dead and continues to be a common protocol when connecting to existing third-party APIs. This makes [clue/reactphp-soap](https://github.com/clue/reactphp-soap) an important piece of the puzzle of bringing @ReactPHP to the masses, in particular when it comes to some of the more *enterprisey* APIs that offer very real business value. Thanks to ReactPHP's component-based design and its existing ecosystem, we can leverage its efficient network protocols to concurrently process a large number of requests, [throttle concurrency](https://clue.engineering/2018/introducing-reactphp-mini-queue), [use HTTP proxy servers](https://clue.engineering/2018/introducing-reactphp-http-proxy) and much more.

If you want to learn more about this project, make sure to check out the project homepage of [clue/reactphp-soap](https://github.com/clue/reactphp-soap). Its documentation describes common usage patterns as well as all the nifty details. It is considered stable and feature complete and has been used in production for a few years already, so you're invited to also give it a try! If you like this project, spreading the word is much appreciated! If you have any feedback or just want to reach out and say hello, I'm happy to hear back and appreciate feedback! Use the comment section below or send a tweet to [@another_clue](https://twitter.com/another_clue).

<blockquote class="twitter-tweet" data-lang="de"><p lang="en" dir="ltr">Just released clue/reactphp-soap v1.0.0! 🎉 Because soap is still a thing (sorry). Long-awaited API overhaul to efficiently send large number of async SOAP requests with <a href="https://twitter.com/reactphp?ref_src=twsrc%5Etfw">@ReactPHP</a>. <a href="https://twitter.com/hashtag/async?src=hash&amp;ref_src=twsrc%5Etfw">#async</a> <a href="https://twitter.com/hashtag/php?src=hash&amp;ref_src=twsrc%5Etfw">#php</a> <a href="https://twitter.com/hashtag/soap?src=hash&amp;ref_src=twsrc%5Etfw">#soap</a> <a href="https://t.co/f7Cvj4h3wC">https://t.co/f7Cvj4h3wC</a></p>&mdash; Christian Lück (@another_clue) <a href="https://twitter.com/another_clue/status/1060267451915665408?ref_src=twsrc%5Etfw">7. November 2018</a></blockquote>

Once again I'd like to thank [Bergfreunde GmbH](https://www.bergfreunde.de/), a German-based online retailer for Outdoor Gear & Clothing, for sponsoring large parts of this development! 🎉 Thanks to sponsors like this, who understand the importance of open source development, I can justify spending time and focus on open source development instead of traditional paid work.

> Did you know that I offer custom development services and issuing invoices for sponsorships of releases and for contributions? Contact me (@clue) for details.