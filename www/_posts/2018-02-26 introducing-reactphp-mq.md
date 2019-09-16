---
title: Introducing clue/reactphp-mq v1.0.0
---

I'm happy to announce the very first stable release of [clue/reactphp-mq](https://github.com/clue/reactphp-mq) 🎉

> Mini Queue, the lightweight in-memory message queue to concurrently do many (but not too many) things at once, built on top of [ReactPHP](https://reactphp.org/).

Now that v1.0.0 has been tagged and released today, let's look into why this is useful, how this can be used and whether this means everybody should uninstall their RabbitMQ cluster? What follows is a short introduction into async PHP with @ReactPHP and how a message queue can help doing many things at once. 

## Doing many things

Many people use PHP and have an idea what it can be used for. Doing many things *at once* is not one of the things PHP is usually associated with, so let's first see what problem [clue/reactphp-mq](https://github.com/clue/reactphp-mq) is trying to solve.

Nowadays, PHP is often used in different kind of backend systems. Whether it's processing some data that came in through an HTTP request, through some backend queuing system (job worker) or some CLI (cron) script that periodically processes data from a database or filesystem. While these may be solving some entirely different problems, what's common to these is that they often need to process a larger number of uniform operations (batch processing).

For example, this post assumes you've crawled an HTML page and find that you now need to send 100 requests to collect information from the following pages. If you want to learn more about this use case, see also [fast webscraping with ReactPHP](http://sergeyzhuk.me/2018/02/12/fast-webscraping-with-reactphp/) by @seregazhuk for a good introduction. HTTP is used as an example here because it's common to a lot of problem, but of course, this can be easily substituted with any other remote API or database system. To further simplify our example let's say we're also done parsing this initial page and have dumped the following 100 URLs into a simple `urls.txt` file, which can now be read like this:

```php
$urls = file('urls.txt', FILE_IGNORE_NEW_LINES);
```

Again, let's go with this for the sake of brevity. In a more realistic scenario we could also load this from a database, JSON files, some other third-party API or heck, even a huge hard-coded array.

The following example uses [kriswallsmith/buzz](https://github.com/kriswallsmith/Buzz) as a lightweight HTTP client library for brevity, but again you can use any library you want:

```bash
$ composer require kriswallsmith/buzz:^0.16
```

The full code to load the list of URLs to fetch and then (sequentially) send a request to each URL could look something like:

```php
$urls = file('urls.txt', FILE_IGNORE_NEW_LINES);

$browser = new Buzz\Browser();

foreach ($urls as $url) {
    $response = $browser->get($url);

    printf(
        "%s has %d bytes\n",
        $url,
        strlen($response->getContent())
    );
}
```

This is code should be pretty self-explanatory; it simply dumps the size of each response after a request completes and the continue to send the next request.

Assuming that each page takes around `0.2s`, this script will run around `20s` for all 100 URLs. The `0.2s` in this example is a rather optimistic assumption, many real-world pages actually take significantly longer. What's worse, if a single HTTP request takes longer (say request number 3), the whole script will block and take even longer before even starting the next request.

In fact, if you monitor your CPU usage while this script is running (or trace its internals), you will find that most of the time, the script will actually do *nothing*. Most of the time, it will simply sit there waiting for some data to arrive. It's obvious that this time can be spent doing more useful things: Enter ReactPHP…

## Concurrency with ReactPHP

[ReactPHP](https://reactphp.org) is a low-level library for event-driven programming in PHP. In a nutshell, it allows you to run multiple I/O operations concurrently.

Applying this to our above example, this means that we can use it to concurrently request all our pages at the same time and then simply *react* to when one of the responses comes in. The following example uses kriswallsmith/buzz as a lightweight HTTP client library for brevity, but again you can use any library you want: For this to work, we'll install the async HTTP client [clue/reactphp-buzz](https://github.com/clue/reactphp-buzz) like this:

```bash
$ composer require clue/buzz-react:^2.0
```

The full code to load the list of URLs to fetch and then (concurrently) send a request to each URL could look something like:

```php
$urls = file('urls.txt', FILE_IGNORE_NEW_LINES);

$loop = React\EventLoop\Factory::create();
$browser = new Clue\React\Buzz\Browser($loop);

foreach ($urls as $url) {
    $browser->get($url)->then(
        function (ResponseInterface $response) use ($url) {
            printf(
                "%s has %d bytes\n",
                $url,
                $response->getBody()->getSize()
            );
        }
    );
}

$loop->run();
```

While this code looks slightly more complicated than the first example, this should still be pretty self-explanatory; it still simply dumps the size of each response after a request completes.

Besides some additional boilerplate, the major difference to the first example is the `$browser->get()` method: While the former version *returned* a response object, the latter returns a [Promise](https://github.com/reactphp/promise) which is *fulfilled* with a response object. Without going into too much detail here, the basic idea here is that each `get()` call actually *starts* a non-blocking operation that will *eventually* complete (async).

This means that the above code actually sends all 100 requests concurrently and then simply waits for each response to arrive. The [Promise](https://github.com/reactphp/promise)-based interface makes it easy to react to when an operation is completed (i.e. either successfully fulfilled or rejected with an error).

Assuming that each page still takes around `0.2s`, this script will theoretically run only for little over `0.2s` for all 100 URLs. Yes, these numbers are no longer multiplied, it actually only has to wait for the *slowest* response. Again, the `0.2s` in this example is a rather optimistic assumption, many real-world pages actually take significantly longer.

In pratice, sending 100 requests *at once* may not be that much of a good idea. While concurrently sending a smaller number of requests should work perfectly fine, sending an excessive number of requests may either take up all resources on your side or it may even get you banned by the remote side if it sees an unreasonable number of requests from your side.

This means that while async processing allows you to get some very impressive speed improvements (`20s` vs `0.2s` total), you will very like run into issues if you overwhelm individual parts of your often complex system.

## Limiting concurrency

This is where [clue/reactphp-mq](https://github.com/clue/reactphp-mq) comes into play: You can use this library to limit the number of concurrent operations. This allows you to effectively rate limit your operations and queue excessives ones so that not too many operations are processed at once.

This library provides a simple API that is easy to use in order to manage any kind of async operation without having to mess with most of the low-level details. You can use this to easily throttle multiple HTTP requests as in this example, database queries or pretty much any API that already uses Promises.

For this to work, we'll install the [clue/reactphp-mq](https://github.com/clue/reactphp-mq) like this:

```bash
$ composer require clue/mq-react
```

The full code to load the list of URLs to fetch and then (with limited concurrency) send a request to each URL could look something like:

```php
$urls = file('urls.txt', FILE_IGNORE_NEW_LINES);

$loop = React\EventLoop\Factory::create();
$browser = new Clue\React\Buzz\Browser($loop);

// each job should use the browser to GET a certain URL
// limit number of concurrent jobs here
$q = new Clue\React\Mq\Queue(10, null, function ($url) use ($browser) {
    return $browser->get($url);
});

foreach ($urls as $url) {
    $q($url)->then(
        function (ResponseInterface $response) use ($url) {
            printf(
                "%s has %d bytes\n",
                $url,
                $response->getBody()->getSize()
            );
        }
    );
}

$loop->run();
```

You'll notice that this code differs only slighty from the previous example and this should still be pretty self-explanatory; it simply dumps the size of each response after a request completes.

The major difference to the previous example is that the `$browser->get()` method is now wrapped in a `Queue` instance and this instance is invoked where a new request is to be sent. Other than that, this code still uses a [Promise](https://github.com/reactphp/promise) which is *fulfilled* with a response object.

This means that from the consumer's perspective is still tries to send all 100 requests concurrently and then simply waits for each response to arrive. The [Promise](https://github.com/reactphp/promise)-based interface makes it easy to react to when an operation is completed (i.e. either successfully fulfilled or rejected with an error).

However, the `Queue` instance is now responsible for managing your operations and ensuring not too many operations are executed at once. It's a very simple and lightweight in-memory implementation of the [leaky bucket](https://en.wikipedia.org/wiki/Leaky_bucket#As_a_queue) algorithm. Without going into too much detail here, this means that you control how many operations can be executed concurrently. If you add a job to the queue and it still below the limit, it will be executed immediately. If you keep adding new jobs to the queue and its concurrency limit is reached, it will not start a new operation and instead queue this for future execution. Once one of the pending operations complete, it will pick the next job from the queue and execute this operation. This queue also has an optional maximum size to avoid taking up all memory for outstanding jobs.

The `new Queue(int $concurrency, ?int $limit, callable $handler)` call can be used to create a new queue instance. You can create any number of queues, for example when you want to apply different limits to different kinds of operations.

The `$concurrency` parameter sets a new soft limit for the maximum number of jobs to handle concurrently. Finding a good concurrency limit depends on your particular use case. It's common to limit concurrency to a rather small value, as doing more than a dozen of things at once may easily overwhelm the receiving side.

The `$limit` parameter sets a new hard limit on how many jobs may be outstanding (kept in memory) at once. Depending on your particular use case, it's usually safe to keep a few hundreds or thousands of jobs in memory. If you do not want to apply an upper limit, you can pass a `null` value which is semantically more meaningful than passing a big number.

The `$handler` parameter must be a valid callable that accepts your job parameters, invokes the appropriate operation and returns a Promise as a placeholder for its future result. Because each operation is expected to be async (non-blocking), you may actually invoke multiple operations concurrently (send multiple requests in parallel).

For our HTTP example, this means that we assume it's safe to concurrently send 10 requests at once and we have no need to limit how many jobs can be queued in total:

```php
$q = new Queue(10, null, function ($url) use ($browser) {
    return $browser->get($url);
});
```

What makes this implementation so powerful is the fact that it relies solely on promises for its API. This means that the consumer of the API does not have to take care of whether it's waiting for an operation that simply takes a while or if the queue has currently set this operation on hold. Each operation may take some time to complete, but due to its async nature you can actually start any number of (queued) operations. Once the concurrency limit is reached, this invocation will simply be queued and this will return a pending promise which will start the actual operation once another operation is completed. This means that this is handled entirely transparently and you do not need to worry about this concurrency limit yourself.

In our example, we assume that the `Queue` should send an HTTP request. But by passing a custom `$handler` parameter, we can actually use this to rate limit any other async operation. Any parameters that are passed to the queue invocation are simply passed through to the `$handler`, so we may also use this to pass additional parameters, such as timeout values and anything that is applicable to our particular use case.

## Blocking

As seen above, this library provides you a powerful, async API by default. If, however, this looks strange to you and you want to integrate this into your traditional, blocking environment, you can also use the more traditional blocking API. This allows you to take advantage of an event driven application to do multiple things at once within your existing, blocking controller functions or any other place.

For this to work, we'll install [clue/reactphp-block](https://github.com/clue/reactphp-block) like this:

```bash
$ composer require clue/block-react
```

The full code to load the list of URLs to fetch and then await sending a request to each URL could look something like:

```php
$urls = file('urls.txt', FILE_IGNORE_NEW_LINES);

/**
 * Concurrently downloads all the given URLs
 *
 * @param string[] $urls       list of URLs to download
 * @return ResponseInterface[] map with a response object for each URL
 * @throws Exception if any of the URLs can not be downloaded
 */
function download(array $urls)
{
    $loop = React\EventLoop\Factory::create();
    $browser = new Clue\React\Buzz\Browser($loop);

    $urls = array_combine($urls, $urls);
    $promise = Queue::all(10, $urls, function ($url) use ($browser) {
        return $browser->get($url);
    });

    return Clue\React\Block\await($promise, $loop);
}

foreach (download($urls) as $url => $response) {
    printf(
        "%s has %d bytes\n",
        $url,
        $response->getBody()->getSize()
    );
}
```

This is code should be pretty self-explanatory; it simply dumps the size of each response after all requests complete.

The major difference to the previous example is that we wrap all async code within a single blocking `download()` function. This function is now used to hide all the async details and provide a normal blocking API. Other than that, this code still uses a [Promise](https://github.com/reactphp/promise) internally which is *fulfilled* with a response object. The blocking API ensures that consumers of this API only see an array of response objects in return.

Note that because this function now returns with an array of all response messages, so we can easily iterate over this array. However, keep in mind that this means the whole response body has to be kept in memory. This should work just fine for our example where we request 100 HTML pages, but may easily take up all your memory for bigger responses, such as file downloads.

## Closing thoughts

Does that mean everybody should uninstall their RabbitMQ cluster? It goes without saying that RabbitMQ is a great project that offers a large number of features that are not provided by this library. If you *need* a message queue with strict guarantees about message delivery, persistence and high availability, RabbitMQ is a very good choice! However, I've been involved in a number of projects where these features may be *overkill* when all your really need is a lightweight way to do *many* (but not *too many*) things at once.

For instance, this project can also be used within your existing RabbitMQ worker: When you receive a single persistent RabbitMQ job message, you may start sending a request to a number of HTTP endpoints. This allows you to synchronously process a single job by asynchronously processing its subtasks.

If you want to learn more about this project, make sure to check out [clue/reactphp-mq](https://github.com/clue/reactphp-mq). If you like this project, spreading the word is much appreciated! If you have any feedback or just want to reach out and say hello, I'm happy to hear back and appreciate feedback! Use the comment section below or send a tweet to [@another_clue](https://twitter.com/another_clue).

<blockquote class="twitter-tweet" data-lang="de"><p lang="en" dir="ltr">Introducing clue/mq-react v1.0.0, the lightweight in-memory message queue to concurrently do many (but not too many) things at once with <a href="https://twitter.com/reactphp?ref_src=twsrc%5Etfw">@ReactPHP</a>. <a href="https://twitter.com/hashtag/async?src=hash&amp;ref_src=twsrc%5Etfw">#async</a> <a href="https://twitter.com/hashtag/php?src=hash&amp;ref_src=twsrc%5Etfw">#php</a> <a href="https://twitter.com/hashtag/concurrency?src=hash&amp;ref_src=twsrc%5Etfw">#concurrency</a> <a href="https://t.co/qUqr8yLfcH">https://t.co/qUqr8yLfcH</a></p>&mdash; Christian Lück (@another_clue) <a href="https://twitter.com/another_clue/status/968087258682351617?ref_src=twsrc%5Etfw">Feb 26, 2018</a></blockquote>

I'd like to thank [Bergfreunde GmbH](https://www.bergfreunde.de/), a German online retailer for Outdoor Gear & Clothing, for sponsoring the first release! 🎉 Thanks to sponsors like this, who understand the importance of open source development, I can justify spending time and focus on open source development instead of traditional paid work.

> Did you know that I offer custom development services and issuing invoices for sponsorships of releases and for contributions? Contact me (@clue) for details.
