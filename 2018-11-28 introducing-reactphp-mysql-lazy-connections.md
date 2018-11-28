Today, we're very happy to announce the immediate availability of the next major beta release of [friends-of-reactphp/mysql](https://github.com/friends-of-reactphp/mysql), the async MySQL database client for [ReactPHP](https://reactphp.org/). 🎉

Now that v0.5.0 has been tagged and released today, let's look into why we believe the new API provides significant new features that warrant a major version bump. While existing code will continue to work without changes, you're highly recommended to consider using the new lazy connections as detailed below. Alright, let's be lazy!

## Eager database connections

[friends-of-reactphp/mysql](https://github.com/friends-of-reactphp/mysql) provides a pure PHP implementation for accessing an existing MySQL database with [ReactPHP](https://reactphp.org/). It allows you to asynchronously connect to your database and send queries to it. Depending on your use case, you can use multiple concurrent connections or use @ReactPHP's vast ecosystem to concurrency access other services (*at the same time*). If you want to learn more about the basics, you may want to check out one of the recent blog posts [introducing MySQL streaming with ReactPHP](https://www.lueck.tv/2018/introducing-reactphp-mysql).

While this project does use a very efficient protocol implementation, there's no denying that certain operations will just take some time: creating a connection to a remote database over a slow link or sending a large SQL statement to a busy database will mostly be limited by how fast the database is able to return its results. Because of this, these kinds of operations are represented by promises that allow you to *react* to when a result is available. In other words, this allows you to *eagerly* await its resolution. To get a better understanding, let's take a look at what an average query looks like with the existing promise-based API:

```php
$uri = 'test:test@localhost/test';
$factory->createConnection($uri)->then(function (ConnectionInterface $connection) {
    $connection->query('SELECT * FROM book')->then(
        function (QueryResult $command) {
            echo count($command->resultRows) . ' row(s) in set' . PHP_EOL;
        },
        function (Exception $error) {
            echo 'Error: ' . $error->getMessage() . PHP_EOL;
        }
    );
    
    $connection->quit();
});
```

### Lazy database connections

The new release now provides a new `createLazyConnection()` method to *lazily* connect on demand and automatically queue all outstanding requests until the underlying connection is ready. Additionally, it implements an "idle" timeout to close the underlying connection when it is unused for some time and will automatically create a new underlying connection on demand again. Let's take a look at what the above query could look like with the new lazy connection API:

```php
$uri = 'test:test@localhost/test';
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
```

This method immediately returns a "virtual" connection implementing the existing `ConnectionInterface` that can be used to interface with your MySQL database. From a consumer side this means that you can start sending queries to the database right away while the underlying connection may still be outstanding. Because creating this underlying connection may take some time, it will enqueue all oustanding commands and will ensure that all commands will be executed in correct order once the connection is ready. In other words, this "virtual" connection behaves just like a "real" connection as described in the `ConnectionInterface` and frees you from having to deal with its async resolution.

## Conclusions

Depending on your particular use case, you may prefer this method or the underlying `createConnection()` which resolves with a promise. For many simple use cases it may be easier to create a lazy connection because it frees you from manually managing connection state and caring about connection timeouts and reconnects for long-running applications. By re-using the existing `ConnectionInterface`, you can simply start using the new `createLazyConnection()` method and use this "virtual" connection without having to deal with its async resolution anymore.

By using existing interfaces, this new release can now be integrated much easier with the existing ecosystem and some of the exciting tech I've introduced in the last blog posts. Additionally, there are plans to use this feature as the base for a future connection pool to automatically manage multiple connections (load-balancing or high-availability setups), but I'll leave this up for another post in the not too far future. But first, make sure to head over to [friends-of-reactphp/mysql](https://github.com/friends-of-reactphp/mysql) and let's celebrate this release 🎉

If you have any feedback or just want to reach out and say hello, I'm happy to hear back and appreciate feedback! Use the comment section below or send a tweet to [@another_clue](https://twitter.com/another_clue).

<blockquote class="twitter-tweet" data-lang="de"><p lang="en" dir="ltr">Just released friends-of-reactphp/mysql v0.5.0! 🎉 It now supports lazy database connections with automatic re-connections and idle timeouts, making long running database applications with <a href="https://twitter.com/reactphp?ref_src=twsrc%5Etfw">@ReactPHP</a> even easier! 🐘💪 <a href="https://twitter.com/hashtag/async?src=hash&amp;ref_src=twsrc%5Etfw">#async</a> <a href="https://twitter.com/hashtag/php?src=hash&amp;ref_src=twsrc%5Etfw">#php</a> <a href="https://t.co/YQtr57mnc0">https://t.co/YQtr57mnc0</a></p>&mdash; Christian Lück (@another_clue) <a href="https://twitter.com/another_clue/status/1067867796078501890?ref_src=twsrc%5Etfw">28. November 2018</a></blockquote>

Once again I'd like to thank [@geertvanbommel](https://github.com/geertvanbommel), a fellow software architect specializing in database batch processing and API development, for sponsoring large parts of this development! 🎉 Thanks to sponsors like this, who understand the importance of open source development, I can justify spending time and focus on open source development instead of traditional paid work. If you follow my posts more regularly, I'm sure you'll recall his name. And if you plan to follow my future posts, I'm sure there are more exiting announcements to follow in the future…

> Did you know that I offer custom development services and issuing invoices for sponsorships of releases and for contributions? Contact me (@clue) for details.
