---
title: Introducing streaming CSV (Comma-Separated Values) with ReactPHP
tags:
  - introducing-reactphp
  - reactphp
  - release
  - csv
  - streaming
  - concurrency
author:
  - Christian Lück
---

I'm happy to announce the very first stable release of [clue/reactphp-csv](https://github.com/clue/reactphp-csv),
the streaming CSV (Comma-Separated Values or Character-Separated Values) parser and encoder for [ReactPHP](https://reactphp.org/). 🎉

Now that v1.0.0 has been tagged and released today, let's look into what CSV is, how it compares to other formats such as NDJSON and how CSV can be used in PHP and ReactPHP.

## CSV format

CSV (Comma-Separated Values or less commonly Character-Separated Values) is a very simple text-based format for storing a large number of (uniform) records, such as a list of user records or log entries.

```
Alice,30
Bob,50
Carol,40
Dave,30
```

While this may look somewhat trivial, this simplicity comes at a price. CSV is limited to untyped, two-dimensional data, so there's no standard way of storing any nested structures or to differentiate a boolean value from a string or integer.

CSV allows for optional field names. Whether field names are used is application-dependant, so this library makes no attempt at *guessing* whether the first line contains field names or field values. For many common use cases it's a good idea to include them like this:

```
name,age
Alice,30
Bob,50
Carol,40
Dave,30
```

CSV allows handling field values that contain spaces, the delimiting comma or even newline characters (think of URLs or user-provided descriptions) by enclosing them with quotes like this:

```
name,comment
Alice,"Yes, I like cheese"
Bob,"Hello
World!"
```

> Note that these more advanced parsing rules are often handled inconsistently by other applications. Nowadays, these parsing rules are defined as part of [RFC 4180](https://tools.ietf.org/html/rfc4180), however many applications started using some CSV-variant long before this standard was defined.

Some applications refer to CSV as Character-Separated Values, simply because using another delimiter (such as semicolon or tab) is a rather common approach to avoid the need to enclose common values in quotes. This is particularly common for systems in Europe (and elsewhere) that use a comma as decimal separator.

```
name;comment
Alice;Yes, I like cheese
Bob;Turn 22,5 degree clockwise
```

CSV files are often limited to only ASCII characters for best interoperability. However, many legacy CSV files often use ISO 8859-1 encoding or some other variant. Newer CSV files are usually best saved as UTF-8 and may thus also contain special characters from the Unicode range. The text-encoding is usually application-dependant, so your best bet would be to convert to (or assume) UTF-8 consistently.

Despite its shortcomings, CSV is widely used and this is unlikely to change any time soon. In particular, CSV is a very common export format for a lot of tools to interface with spreadsheet processors (such as Excel, Calc etc.). This means that CSV is often used for historical reasons and using CSV to store structured application data is usually not a good idea nowadays – but exporting to CSV for known applications continues to be a very reasonable approach.

## CSV vs. NDJSON

As an alternative, if you want to process structured data in a more modern JSON-based format, you may want to use [clue/reactphp-ndjson](https://github.com/clue/reactphp-ndjson) to process newline-delimited JSON (NDJSON) files (`.ndjson` file extension). So in contrast, let's look at the exact same example expressed as a simple NDJSON file, let's call this `users.ndjson`:

```JSON
{"name":"Alice","age":30,"comment":"Yes, I like cheese"}
{"name":"Bob","age":50,"comment":"Hello\nWorld!"}
```

If you understand JSON and you're now looking at this newline-delimited JSON for the first time, you should already know everything you need to know to understand NDJSON: As the name implies, this format essentially consists of individual lines where each individual line is any valid JSON text and each line is delimited with a newline character.

While NDJSON helps avoiding some of CSV's shortcomings, it is still a (relatively) young format while CSV files have been used in production systems for decades. This means that if you want to interface with an existing system, CSV is more likely to be supported as is in fact often the *lowest common denominator* for many interactions, even in today's systems. The following sections thus assume CSV as the format of choice, but otherwise this can equally be applied to NDJSON or other structured formats. If you want to learn more about NDJSON, you may want to check out one of the [previous blog posts](https://clue.engineering/2018/introducing-reactphp-ndjson).

## Parsing CSV with PHP

Now that we have an idea of what CSV looks like, let's look into how we can process our `users.csv` file in PHP. Fortunately, PHP provides native CSV support through the built-in [`fgetcsv()`](https://www.php.net/manual/en/function.fgetcsv.php) and [`str_getcsv()`](https://www.php.net/manual/en/function.str-getcsv.php) functions. This makes parsing CSV files somewhat trivial in PHP:

```php
$stream = fopen('users.csv', 'r');

while (($user = fgetcsv($stream)) !== false) {
    echo 'hello ' . $user[0] . PHP_EOL;
}
```

Similarly, appending a new user to the existing list is really simple:

```php
$user = [
    'Dave',
    'CSV is easy'
];

$stream = fopen('users.csv', 'a');
fputcsv($stream, $user);
```

Nothing of this should be really surprising to you if you've ever worked with streams in PHP. In fact, if you want to add plain CSV support to your existing projects, you won't necessarily need a dedicated library for CSV.

That being said, using an existing CSV library may help with proper error handling, converting the input encoding and parsing field names as described above. If you're looking for one, maybe give the excellent [league/csv](https://github.com/thephpleague/csv) package a try.

The nice thing about the above examples is that they only use PHP streams and as such work with CSV files of arbitrary sizes. This means that this will never try to load the whole file into memory at once and instead only process one row after another. It is a common problem to load the whole CSV file via `file()` or `file_get_contents()` into memory and subsequently call the CSV parser on each row.

Now after an introduction to the basics of CSV, let's look into how this can be done with ReactPHP and why this may make sense.

## Streaming CSV with ReactPHP

To recap, [ReactPHP](https://reactphp.org) is a low-level library for event-driven programming in PHP. In a nutshell, it allows you to run multiple I/O operations concurrently and "react" to incoming events.

Applying this to our above example, this means that we can use it to process our CSV file as a stream we can read from and then "react" to each record. For this to work, we'll install the new streaming CSV parser [clue/reactphp-csv](https://github.com/clue/reactphp-csv) like this:

```bash
$ composer require clue/reactphp-csv:^1.0
```

The full code to stream this CSV file and emit some message for each record could look something like this:

```php
$loop = React\EventLoop\Factory::create();

$stream = new Clue\React\Csv\AssocDecoder(
    new React\Stream\ReadableResourceStream(
        fopen('users.csv', 'r'),
        $loop
    )
);

$stream->on('data', function ($user) {
    echo 'Hello ' . $user['name'] . PHP_EOL;
});
$stream->on('end', function () {
    echo '[DONE]' . PHP_EOL;
});

$loop->run();
```

While this code looks slightly more complicated than the previous example, this should still be pretty self-explanatory; it still simply prints a message for each user record.

Besides some additional boilerplate, the major difference to the first example is that this no longer imperatively loads the records from a stream. It merely says that the given CSV file should be read and interpreted by the CSV decoder and we "react" to its `data` event.

This implies that this example also supports files of arbitrary sizes as only small chunks will be processed in memory and ReactPHP takes care of invoking your event handlers as expected. Because it can start processing records without having to wait for the whole file to be read into memory, this yields some interesting benchmarking results. On my laptop, parsing a 90 MiB CSV file with around 120000 records takes around 4 seconds (~30000 records/s) while memory consumptions stays rather constant at a few megabytes. Arguably, this is way faster than many people would probably expect PHP to be. (As always, don't trust some random stranger when it comes to performance – you're invited to run your own benchmarks and share what you've found.)

Arguably, this example is a bit "overkill" if you only want to stream a few records and note that this example uses `fopen()` for illustration purposes only. A truly async application should not use this, as the file system is inherently blocking. Luckily, streams are one of the core abstractions in ReactPHP, so that many different stream abstractions are available for a large number of use cases (TCP/IP connections, HTTP requests, databases etc., see also [stream documentation](https://reactphp.org/stream/) for more details). Having established these streaming concepts means that we can now use CSV in some advanced contexts…

## Concurrent CSV batch processing

So far, our example code is still rather simple. While loading the CSV file into memory is indeed already non-blocking, we don't really do anything meaningful with our data. So what if we want to process each user record in a meaningful way? To stick to our example, let's assume we want to POST each user object to a (RESTful) HTTP API.

CSV batch processing is a very common approach for many import/export jobs, in PHP and elsewhere. In a traditional, blocking environment this means executing one "job" per record. Doing some simple math here means that processing 100 records by sending 100 HTTP requests and estimating each HTTP request to take 200 ms would take a total time of 20 seconds for all jobs to complete sequentially.

In one of the previous posts, we've looked into [managing flux and doing many (but not too many) things concurrently with ReactPHP](https://clue.engineering/2018/introducing-reactphp-flux). If you're new to the concept of concurrently processing multipe things at once with ReactPHP, go check out that post, I'll wait. To recap, we can use ReactPHP to process multiple of these jobs concurrently. Ideally, we could start all jobs at the same time and only have to wait for slowest one to complete (200 ms instead of 20 seconds). When we only have a few jobs to perform (say a dozen or so), this is a reasonable approach that works well in practice. However, if we have some thousand jobs to perform, we can no longer start all at the same time as this may easly take up all resources on your side or overwhelm the receiving side.

This is where [clue/reactphp-flux](https://github.com/clue/reactphp-flux) comes into play: You can use this library to run multiple operations while managing the throughput of the stream (flux). This allows you to effectively rate limit your operations and queue excessives ones so that not too many operations are processed at once. You can control the concurrency limit, so that by allowing it to process 10 operations at the same time, you can thus process this large input list around 10 times faster and at the same time you're no longer limited how many records this list may contain (think processing millions of records). Doing some simple math here means that processing 100 records by sending 100 HTTP requests in total and 10 HTTP requests concurrently and estimating each HTTP request to take 200 ms would take a total time of 2 seconds for all jobs to complete.

For this to work, we'll install [clue/reactphp-flux](https://github.com/clue/reactphp-flux) and [clue/reactphp-buzz](https://github.com/clue/reactphp-buzz) like this:

```bash
$ composer require clue/reactphp-flux:^1.1 clue/buzz-react
```

The full code to load the list of users and then (with limited concurrency) send a request for each user could look something like:

```php
$loop = React\EventLoop\Factory::create();
$browser = new Clue\React\Buzz\Browser($loop);
$browser = $browser->withBase('http://example.com/api');

// load a huge number of users to process from the CSV file
$stream = new Clue\React\Csv\AssocDecoder(
    new React\Stream\ReadableResourceStream(
        fopen('users.csv', 'r'),
        $loop
    )
);

// process all users by processing through transformer
// each job should use the browser to POST a certain user
// limit number of concurrent jobs here
$promise = Transformer::all($stream, 10, function ($user) use ($browser) {
    return $browser->post('/', [], json_encode($user));
});

// log transformed output results
$promise->then(
    function ($count) {
        echo 'Successfully processed all ' . $count . ' users' . PHP_EOL;
    },
    function (Exception $e) {
        echo 'An error occured: ' . $e->getMessage() . PHP_EOL;
        if ($e->getPrevious()) {
            echo 'Previous: ' . $e->getPrevious()->getMessage() . PHP_EOL;
        }
    }
);

$loop->run();
```

Again, this code looks slightly more complicated than the previous example, but this should still be pretty self-explanatory; it reads from a CSV input file, processes each user by sending a HTTP POST request and waits for all jobs to complete. The major difference to the previous example is that the input stream is now passed to the `Transformer` which takes care of invoking the given callback function for each record in this stream. This callback function uses a [Promise](https://github.com/reactphp/promise)-based interface to send an HTTP request (which may take some time). The `Transformer` is responsible for invoking this handler function once for each record while managing the input stream flow (flux) by throttling it to ensure that not too many records are ever loaded into memory at once.

What makes this implementation so powerful is the fact that it relies solely on streams and promises for its API. This library provides a simple API that is easy to use in order to manage any kind of async operation without having to mess with most of the low-level details. You can use this to easily throttle multiple HTTP requests as in this example, database queries or pretty much any API that already uses Promises. Similarly, streams are one of the core abstractions in ReactPHP. This means that many different stream implementations are already available for a large number of use cases that would otherwise use the exact same processing logic. If you want to learn more about managing flux, make sure to check out the [previous blog post](https://clue.engineering/2018/introducing-reactphp-flux).

## Conclusions

CSV may not be new and may not be pretty, but it's far from being dead and continues to be a very common and useful import/export format. Streaming CSV records and CSV batch processing is a powerful approach to processing large number of records. Concurrently processing multiple records at once may significantly improve performance for many use cases that rely on I/O operations (20 seconds vs. 2 seconds in our example).

It goes without saying that this project does not aim to replace RabbitMQ or other projects that offers a large number of features that are not provided by this library. If you need a message queue with strict guarantees about message delivery, persistence and high availability, RabbitMQ is a very good choice! However, I've been involved in a number of projects where these features may be overkill when all your really need is a lightweight way to do many (but not too many) things at once.

If you want to learn more about this project, make sure to check out [clue/reactphp-csv](https://github.com/clue/reactphp-csv). If you like this project, spreading the word is much appreciated! If you have any feedback or just want to reach out and say hello, I'm happy to hear back and appreciate feedback! Use the comment section below or send a tweet to [@another_clue](https://twitter.com/another_clue).

<blockquote class="twitter-tweet" data-lang="de"><p lang="en" dir="ltr">Introducing streaming CSV (Comma-Separated Values) parser and encoder for <a href="https://twitter.com/reactphp?ref_src=twsrc%5Etfw">@ReactPHP</a>. Efficiently process large CSV files with thousands or millions of records concurrently with PHP. <a href="https://twitter.com/hashtag/async?src=hash&amp;ref_src=twsrc%5Etfw">#async</a> <a href="https://twitter.com/hashtag/php?src=hash&amp;ref_src=twsrc%5Etfw">#php</a> <a href="https://twitter.com/hashtag/concurrency?src=hash&amp;ref_src=twsrc%5Etfw">#concurrency</a> <a href="https://twitter.com/hashtag/streaming?src=hash&amp;ref_src=twsrc%5Etfw">#streaming</a> <a href="https://t.co/Uo4rAgh97k">https://t.co/Uo4rAgh97k</a></p>&mdash; Christian Lück (@another_clue) <a href="https://twitter.com/another_clue/status/1029405050232291333?ref_src=twsrc%5Etfw">14. August 2018</a></blockquote>

