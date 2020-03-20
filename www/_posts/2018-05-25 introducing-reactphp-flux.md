---
title: Introducing concurrent stream processing with ReactPHP and Flux
tags:
  - introducing-reactphp
  - reactphp
  - release
  - flux
  - streaming
  - concurrency
---

I'm happy to announce the very first stable release of [clue/reactphp-flux](https://github.com/clue/reactphp-flux),
the lightweight stream processor to concurrently do many (but not too many) things at once, built on top of [ReactPHP](https://reactphp.org/). 🎉

Now that v1.0.0 has been tagged and released today, let's look into why streaming processing is useful, how this compares to keeping many operations in memory and how this can be used to process a large number of operations with ReactPHP.

## Concurrency with ReactPHP

In one of the previous posts, we've looked into [doing many (but not too many) things concurrently with ReactPHP](https://clue.engineering/2018/introducing-reactphp-mq). If you're new to the concept of concurrently processing multipe things at once with ReactPHP, go check out that post, I'll wait.

The gist of this previous post is that [ReactPHP](https://reactphp.org/) allows you to do multiple things concurrently. For instance, if you want to process a list of 100 (RESTful) HTTP API requests, you no longer have to wait for them to be completed sequentially, but can start multiple operations at once. By using [clue/reactphp-mq](https://github.com/clue/reactphp-mq), you can control this process to use for example 10 requests concurrently and thus make this process around 10 times faster.

Excessive operations are automatically queued in memory, which means that this does not require any external services and can thus process these operations with minimal overhead. Storing outstanding operations in memory makes sense for a large number of use cases, however, this also means that this is limited to certain use cases.

So what if you have more than a few dozens or hundreds of operations (think thousands or even millions)? Or similarly, what if you need to process a list of operations with an unknown size, such as when getting this list from a remote service? In this case, you probably don't want to store all outstanding operations in memory at once. Instead, let's look into how *streaming* this list can help.

## Streaming with ReactPHP

We've established the idea that we need to process some list of operations. This example uses an array of user objects where each user has a some arbitrary properties. This can easily be adjusted for many different use cases, such as storing for example products instead of users, assigning additional properties or having a significantly larger number of records.

Let's look at how this list of user objects could look like, for example, let's call this our `users.ndjson`:

```JSON
{ "name": "alice", "birthday": "2017-01-01", "ip": "1.1.1.1" }
{ "name": "bob",   "birthday": "2006-01-01", "ip": "2.1.1.1" }
{ "name": "carol", "birthday": "1995-01-01", "ip": "3.1.1.1" }
{ "name": "dave",  "birthday": "1983-01-01", "ip": "4.1.1.1" }
{ "name": "eve",   "birthday": "1972-01-01", "ip": "5.1.1.1" }
…
```

This example uses the NDJSON format to store a list of user objects in a file, but you may use any streaming format you prefer. If you want to learn more about NDJSON and how this compares to CSV and other formats, see also the previous post [introducing streaming newline-delimited JSON (NDJSON)](https://clue.engineering/2018/introducing-reactphp-ndjson).

To recap, [ReactPHP](https://reactphp.org) is a low-level library for event-driven programming in PHP. In a nutshell, it allows you to run multiple I/O operations concurrently and "react" to incoming events. Applying this to our above example, this means that we can use it to process our NDJSON file as a stream we can read from and then "react" to each record. For this to work, we'll install the streaming NDJSON parser [clue/ndjson-reactphp](https://github.com/clue/reactphp-ndjson) like this:

```bash
$ composer require clue/ndjson-react:^1.0
```

The full code to stream this NDJSON file and emit some message for each record could look something like this:

```php
$loop = React\EventLoop\Factory::create();

$stream = new Clue\React\NDJson\Decoder(
    new React\Stream\ReadableResourceStream(
        fopen('users.ndjson', 'r'),
        $loop
    ),
    true
);

$stream->on('data', function ($user) {
    echo 'Hello ' . $user['name'] . PHP_EOL;
});
$stream->on('end', function () {
    echo '[DONE]' . PHP_EOL;
});

$loop->run();
```

While this code may look a bit strange if you're new to async processing, this should still be pretty self-explanatory; it simply prints a message for each user record.

One interesting effect of using a streaming approach here is that this implies that this example actually supports files of arbitrary sizes as only small chunks will be processed in memory and ReactPHP takes care of invoking your event handlers as expected. In fact, not having to load the whole file to be read into memory means that this is way faster than many people would probably expect PHP to be. On my laptop this yields around 5 Gbit/s, so it's probably faster than your average network connection or persistent storage. (As always, don't trust some random stranger when it comes to performance – you're invited to run your own benchmarks and share what you've found.)

## Async processing

So far, our example code is still rather simple. While loading the file into memory is indeed already non-blocking, we don't really do anything meaningful with our data. So what if we want to process each user record in a meaningful way? To stick to our example, let's assume we want to access some third-party geolocation API for each user object with a (RESTful) HTTP API request.

For this to work, we'll access `ipapi.co` and install [clue/reactphp-buzz](https://github.com/clue/reactphp-buzz) like this:

```bash
$ composer require clue/buzz-react
```

Its API can now be used like this:

```php
$loop = React\EventLoop\Factory::create();
$browser = new Clue\React\Buzz\Browser($loop);

$browser->get("https://ipapi.co/1.1.1.1/country_name/")->then(
    function (ResponseInterface $response) {
        echo $response->getBody();
    }
);

$loop->run();
```

This should be pretty self-explanatory; it simply prints the country name for a given IP.

## Managing flux

Now comes the tricky part: We want to run multiple of these operations, one for each user. How do we run many (but not too many) of these operations while at the same time ensuring we properly manage flow of the input stream without reading too much into memory at once? This is where [clue/reactphp-flux](https://github.com/clue/reactphp-flux) comes into play: You can use this library to run multiple operations while managing the throughput of the stream (flux). This allows you to effectively rate limit your operations and queue excessives ones so that not too many operations are processed at once. You can control the concurrency limit, so that by allowing it to process 10 operations at the same time, you can thus process this large input list around 10 times faster and at the same time you're no longer limited how many records this list may contain (think processing millions of records).

This library provides a simple API that is easy to use in order to manage any kind of async operation without having to mess with most of the low-level details. You can use this to easily throttle multiple HTTP requests as in this example, database queries or pretty much any API that already uses Promises.

For this to work, we'll install the [clue/reactphp-flux](https://github.com/clue/reactphp-flux) like this:

```bash
$ composer require clue/reactphp-flux
```

The full code to load the list of URLs to fetch and then (with limited concurrency) send a request to each URL could look something like:

```php
$loop = React\EventLoop\Factory::create();
$browser = new Clue\React\Buzz\Browser($loop);

// load a huge number of users to process from NDJSON file
$input = new Clue\React\NDJson\Decoder(
    new React\Stream\ReadableResourceStream(
        fopen(__DIR__ . '/users.ndjson', 'r'),
        $loop
    ),
    true
);

// each job should use the browser to GET a certain URL
// limit number of concurrent jobs here
$transformer = new Transformer(10, function ($user) use ($browser) {
    // look up country for this IP
    return $browser->get("https://ipapi.co/$user[ip]/country_name/")->then(
        function (ResponseInterface $response) use ($user) {
            // response successfully received
            // add country to user array and return updated user
            $user['country'] = (string)$response->getBody();

            return $user;
        }
    );
});

// process all users by piping through transformer
$input->pipe($transformer);

// log transformed output results
$transformer->on('data', function ($user) {
    echo $user['name'] . ' is from ' . $user['country'] . PHP_EOL;
});
$transformer->on('end', function () {
    echo '[DONE]' . PHP_EOL;
});

$loop->run();
```

You'll notice that this code includes both previous examples and combines them in a piping context: It loads all users from the input stream, pipes this into our new `Transformer` and then dumps the result for each user.

The major difference to the previous example is that the `$browser->get()` method is now wrapped in a `Transformer` instance and this instance is responsible for managing its async processing. Other than that, this code still uses the same streaming logic and a [Promise](https://github.com/reactphp/promise) which is *fulfilled* with the user's country name.

This means that from the consumer's perspective is still tries to pipe the whole NDJSON stream into the `Transformer `and then process its results as soon as they arrive. It uses the same streaming interfaces as the previous example which makes it easy to react to when an operation is completed.

However, the `Transformer` instance is now responsible for managing your operations and ensuring not too many operations are executed at once. It's a very simple and lightweight in-memory implementation of the [leaky bucket](https://en.wikipedia.org/wiki/Leaky_bucket#As_a_queue) algorithm. Without going into too much detail here, this means that you control how many operations can be executed concurrently. If you add a job to the queue and it still below the limit, it will be executed immediately. If you keep adding new jobs to the queue and its concurrency limit is reached, it will not start a new operation and instead queue this for future execution. Once one of the pending operations complete, it will pick the next job from the queue and execute this operation. This queueing mechanism automatically notifies the pipe source so that it will actually `pause()` reading from the NDJSON input stream when its limit is reached and will automatically `resume()` reading from the NDJSON input stream when it is below the limit again. This back-pressure thus avoids taking up all memory for outstanding jobs. This means that this is handled entirely transparently and you do not need to worry about this concurrency limit yourself.

The `new Transformer(int $concurrency, callable $handler)` call can be used to create a new transformer instance. You can create any number of transformation streams, for example when you want to apply different transformations to different kinds of streams.

The `$concurrency` parameter sets a new soft limit for the maximum number of jobs to handle concurrently. Finding a good concurrency limit depends on your particular use case. It's common to limit concurrency to a rather small value, as doing more than a dozen of things at once may easily overwhelm the receiving side. Using a `1` value will ensure that all jobs are processed one after another, effectively creating a "waterfall" of jobs.

The `$handler` parameter must be a valid callable that accepts your job parameter (the data from its writable side), invokes the appropriate operation and returns a Promise as a placeholder for its future result (which will be made available on its readable side).

What makes this implementation so powerful is the fact that it relies solely on streams and promises for its API. This means that the consumer of the API does not have to take care of whether it's waiting for an operation that simply takes a while or if the queue has currently set this operation on hold. Each operation may take some time to complete, but due to its async nature you can actually start any number of (queued) operations. Once the concurrency limit is reached, this invocation will simply be queued and the next operation will only be started once another operation is completed. This means that this is handled entirely transparently and you do not need to worry about this concurrency limit yourself.

In our example, we assume that the `Transformer` should send an HTTP request. But by passing a custom `$handler` parameter, we can actually use this to rate limit any other async operation. You can use this to concurrently run multiple HTTP requests, database queries or pretty much any API that already uses Promises.

## Conclusions

Stream processing is a really powerful approach when it comes to processing a large number of records and by now I hope I could show you how concurrently processing streams with the help of Flux is a really powerful addition to this toolset. Managing flux is a critical aspect of many async applications. Using this project, you can easily control the concurrency limit and thus process streams significantly faster than processing each operation sequentially.

In one of the previous posts, we've looked into using an in-memory queue to [do many (but not too many) things concurrently with ReactPHP](https://clue.engineering/2018/introducing-reactphp-mq). Arguably, this may be simpler to integrate if you want to handle a few dozens or hundreds of operations. However, unlike that project, stream processing does not require you to keep the whole list in memory and thus does not limit you in how many entries you can process.

It goes without saying that this project does not aim to replace RabbitMQ or other projects that offers a large number of features that are not provided by this library. If you *need* a message queue with strict guarantees about message delivery, persistence and high availability, RabbitMQ is a very good choice! However, I've been involved in a number of projects where these features may be *overkill* when all your really need is a lightweight way to do *many* (but not *too many*) things at once.

In case you're wondering: The name "flux" refers to its formal definition of "[…] the quantity which passes through a surface or substance". Any resemblance to other projects using similar names is purely coincidental...

If you want to learn more about this project, make sure to check out [clue/reactphp-flux](https://github.com/clue/reactphp-flux). If you like this project, spreading the word is much appreciated! If you have any feedback or just want to reach out and say hello, I'm happy to hear back and appreciate feedback! Use the comment section below or send a tweet to [@another_clue](https://twitter.com/another_clue).

I'd like to thank [@geertvanbommel](https://github.com/geertvanbommel), a fellow software architect specializing in database batch processing and API development, for sponsoring the first release! 🎉 Thanks to sponsors like this, who understand the importance of open source development, I can justify spending time and focus on open source development instead of traditional paid work.

> Did you know that I offer custom development services and issuing invoices for sponsorships of releases and for contributions? Contact me (@clue) for details.
