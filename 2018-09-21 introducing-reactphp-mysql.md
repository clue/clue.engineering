Today, we're very happy to announce the immediate availability of the next major beta release of [friends-of-reactphp/mysql](https://github.com/friends-of-reactphp/mysql), the async MySQL database client for [ReactPHP](https://reactphp.org/). 🎉

Now that v0.4.0 has been tagged and released today, let's look into why I think this is not only a major milestone for this project, but could also possibly be a game changer in how people use databases with ReactPHP and eventually maybe with PHP in general.

This post aims more for the "why" instead of "what" has changed. If you're upgrading from a previous version of this project, you may want to take a look at the [changelog](https://github.com/friends-of-reactphp/mysql/releases) describing all the changes in greater detail. Alright, so let's dive right in.

## Promise all the things!

Originally, this project was maintained by [Jin Hu](https://github.com/bixuehujin) who did an excellent job figuring out all the protocol details and building an API that can be consumed with ReactPHP. All this with just plain PHP, without requiring any custom extensions. Again, thank you!

Around 6 months ago, he handed over this project to @friends-of-reactphp to take over maintenance and to address a number of outstanding feature requests and issues. In the meantime, we've used this as a base to successfully address some of these minor issues and released a number of minor maintenance releases. In the last months, we have prepared some major changes that we are now releasing with the v0.4.0 version.

One of the major changes is that its APIs now use [promises](https://github.com/reactphp/promise) consistently as return values instead of accepting callback functions. While we understand that BC breaks may be frustrating when updating and usually try to avoid these as a consequence, we believe that it's very well worth it in this instance. To get a better understanding, let's take a look at what an average query looks like with the old API vs. the new promise-based API:

```php
// old
$connection->query('SELECT * FROM user', function (QueryCommand $command) {
    if ($command->hasError()) {
        echo 'Error: ' . $command->getError()->getMessage() . PHP_EOL;
    } elseif (isset($command->resultRows)) {
        var_dump($command->resultRows);
    }
});

// new
$connection->query('SELECT * FROM user')->then(function (QueryResult $result) {
    var_dump($result->resultRows);
}, function (Exception $error) {
    echo 'Error: ' . $error->getMessage() . PHP_EOL;
});
```

Code-wise this may seem like a small change. However, it is a small change with a huge impact: Promises are one of the core building blocks of ReactPHP libraries. By allowing you to take advantage of promise chaining, we can significantly simplify integration with the vast ReactPHP ecosystem.

For example, we can use this along with ReactPHP's [HTTP server component](https://github.com/reactphp/http) to build a very simple JSON-based HTTP API endpoint (I'll avoid the term "RESTful" here):

```php
$server = new Server(function (ServerRequestInterface $request) use ($connection) {
    return $connection->query(
        'SELECT * FROM user WHERE id = ?',
        [$request->getQueryParams()['id'] ?? -1]
    )->then(function (QueryResult $result) {
        return new Response(
            $result->resultRows ? 200 : 404,
            array(
                'Content-Type' => 'application/json'
            ),
            json_encode($result->resultRows[0] ?? null)
        );
    });
});
```

The example output from an HTTP request could look something like this:

```
$ curl -v http://localhost:8080/?id=1
…
HTTP/1.1 200 OK
Content-Type: application/json
Content-Length: …

{"id":"1","name":"Alice","ip":"1.2.3.4"}
```

## Streaming large result sets

The above example should be simple enough to understand how you can send any SQL statement to your MySQL database, fetch the results and then send a formatted HTTP response back for your incoming HTTP request. This works very well for smaller result sets, even when you have a larger number of concurrent incoming HTTP requests and thus may end up sending a lot of queries to your database.

Now let's assume instead of fetching only a single user from the database, we may want to fetch *all* users (or any large subset, such as *new* users or using any other criteria). Having millions of user records in a MySQL database is nothing particularly stressful for your database. However, if we have millions of records in our database, we probably don't want to fetch all these rows and keep them in memory in our script.

Enter streaming: The new version now provides a new `queryStream()` method which works very similar to the `query()` method in the previous example. However, instead of buffering the full result set in memory and then resolving the promise, it uses streams to emit `data` events for each individual row. This allows us to process result sets with thousands or millions of rows, without ever having to store all of this in memory at once.

Keeping the previous example, we can use this along with a [clue/reactphp-ndjson](https://github.com/clue/reactphp-ndjson) to build a streaming, newline-delimited JSON (NDJSON) HTTP API endpoint:

```php
$server = new Server(function (ServerRequestInterface $request) use ($connection) {
    $stream = $connection->queryStream(
        'SELECT * FROM user WHERE id > ?',
        [$request->getQueryParams()['id'] ?? -1]
    );
    
    return new Response(
        200,
        array(
            'Content-Type' => 'application/x-ndjson'
        ),
        new \Clue\React\NDJson\Encoder($stream)
    );
});
```

The example output from an HTTP request could look something like this:

```
$ curl -v http://localhost:8080/?id=0
…
HTTP/1.1 200 OK
Content-Type: application/x-ndjson
Transfer-Encoding: chunked

{"id":"1","name":"Alice","ip":"1.2.3.4"}
{"id":"2","name":"Bob","ip":"20.2.3.4"}
{"id":"3","name":"Carol","ip":"30.2.3.4"}
…
```

If you want to learn more about NDJSON, you may want to check out one of the [previous blog posts](https://clue.engineering/2018/introducing-ndjson-reactphp). Similarly, you can also use [streaming CSV output](https://clue.engineering/2018/introducing-reactphp-csv) or pretty much any other format you prefer.

## Looking forward

By using standard promise-based and streaming interfaces, this project can now be integrated much easier with the existing ecosystem and some of the exciting tech I've introduced in the last blog posts. For example, imagine [concurrent stream processing](https://clue.engineering/2018/introducing-reactphp-flux) and [concurrent CSV processing](https://clue.engineering/2018/introducing-reactphp-csv) with a MySQL query as an input stream instead…

You see, this blog post is barely touching the surface of why I think this release is a major milestone. I want to keep this blog post short(er), so I'll leave this up for another post soon-ish. But first, make sure to head over to [friends-of-reactphp/mysql](https://github.com/friends-of-reactphp/mysql) and let's celebrate this release 🎉

Once again I'd like to thank [@geertvanbommel](https://github.com/geertvanbommel), a fellow software architect specializing in database batch processing and API development, for sponsoring large parts of this development! 🎉 Thanks to sponsors like this, who understand the importance of open source development, I can justify spending time and focus on open source development instead of traditional paid work. If you follow my posts more regularly, I'm sure you'll recall his name. And if you plan to follow my future posts, I'm sure there are more exiting announcements to follow soon…

> Did you know that I offer custom development services and issuing invoices for sponsorships of releases and for contributions? Contact me (@clue) for details.

If you have any feedback or just want to reach out and say hello, I'm happy to hear back and appreciate feedback! Use the comment section below or send a tweet to [@another_clue](https://twitter.com/another_clue).

<blockquote class="twitter-tweet" data-lang="de"><p lang="en" dir="ltr">Just released friends-of-reactphp/mysql v0.4.0! 🎉 It includes many long awaited features: Promise-based APIs and streaming large result sets! Efficiently process thousands or millions of records from your <a href="https://twitter.com/MySQL?ref_src=twsrc%5Etfw">@MySQL</a> database with @ReactpPHP. <a href="https://twitter.com/hashtag/async?src=hash&amp;ref_src=twsrc%5Etfw">#async</a> <a href="https://twitter.com/hashtag/php?src=hash&amp;ref_src=twsrc%5Etfw">#php</a> <a href="https://t.co/b1Hv408RtD">https://t.co/b1Hv408RtD</a></p>&mdash; Christian Lück (@another_clue) <a href="https://twitter.com/another_clue/status/1043161821409157129?ref_src=twsrc%5Etfw">21. September 2018</a></blockquote>
