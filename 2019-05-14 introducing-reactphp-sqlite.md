Today, I'm happy to announce the very first stable `v1.0.0` release of [clue/reactphp-sqlite](https://github.com/clue/reactphp-sqlite), the async [SQLite](https://www.sqlite.org/) database for [ReactPHP](https://reactphp.org/) 🎉

Now that v1.0.0 has been tagged and released today, let's take a look at how we can use an async SQLite database in a non-blocking PHP application, how it compares to other databases and why I think @ReactPHP's design makes it a perfect fit.

## About SQLite

[SQLite](https://www.sqlite.org/) is a widespread and efficient in-process database. It offers a common SQL interface to process queries to work with its relational data in memory or persist to a simple, portable database file. Its lightweight design makes it an ideal candidate for an embedded database in portable (CLI) applications, test environments and much more.

This library provides you a simple API to work with your SQLite database from within PHP. Because working with SQLite and the underlying filesystem is inherently blocking, this project is built as a lightweight non-blocking process wrapper around it, so you can query your data without blocking your main application.

```php
$loop = React\EventLoop\Factory::create();
$factory = new Clue\React\SQLite\Factory($loop);

$db = $factory->openLazy('users.db');
$db->exec('CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY AUTOINCREMENT, name STRING)');

$name = 'Alice';
$db->query('INSERT INTO users (name) VALUES (?)', [$name])->then(
    function (Clue\React\SQLite\Result $result) use ($name) {
        echo 'New ID for ' . $name . ': ' . $result->insertId . PHP_EOL;
    }
);

$db->quit();

$loop->run();
```

Even if you've never worked with SQLite or ReactPHP's async APIs, you should be able to understand what's going on in this simple example: It uses some simple SQL statements to create a table "users" and inserts a new user "Alice" into this list of users. One of the nice properties of SQLite is that is can simply persist these changes to a single database file (`users.db` in this example) without requiring any special database server setup.

If you've ever worked with [async MySQL connection](https://www.lueck.tv/2018/introducing-reactphp-mysql-lazy-connections) or [async Redis connection](https://www.lueck.tv/2019/introducing-reactphp-redis) in ReactPHP, you will find that it provides a very similar (perhaps *familiar*) API. Its Promise-based API allows you to enqueue any number of queries while the underlying database process may still be pending and you can react to the query results you care about.

Their APIs may be similar, but under the hood, this database binding is special: Unlike the previous database clients that use non-blocking protocol implementations for their I/O operations, this project is implemented as a lightweight non-blocking process wrapper around PHP's native SQLite database extension (`ext-sqlite3`). This is done because working with SQLite APIs and the underlying filesystem for persistence is inherently blocking. By wrapping all such operations in a child worker process that will automatically be started on demand, we can take advantage of the existing SQLite implementation without blocking the main application. Combined with ReactPHP's event-driven architecture and thanks to [async child process I/O](https://www.lueck.tv/2019/introducing-reactphp-child-process) using an [efficient NDJSON/JSON-RPC](https://www.lueck.tv/2018/introducing-reactphp-ndjson) communication, this can be used to process hundreds of queries per second.

## Conclusions

[SQLite](https://www.sqlite.org/) is an efficient and versatile database. Its lightweight design makes it an ideal candidate for an embedded database in portable (CLI) applications, test environments and much more. Combined with ReactPHP's event-driven architecture and this library's efficient I/O implementation, this can be used to efficiently process a large quantity of entries in a number of different use cases. If you want to use it as a more traditial data store in your application, we've got you covered!

[ReactPHP's vast ecosystem](https://github.com/reactphp/react/wiki/Users) features a large number of existing client implementations for pretty much any widespread protocol and database system out there – now including the perhaps [most used database](https://www.sqlite.org/mostdeployed.html) in existence. A future blog post will look into ways on how we can use this SQLite database adapter to provide mocked data access in a test suite for some higher-level integration tests instead of relying on an actual database server setup (e.g. MySQL) for web applications. In the meantime, if you want to learn more about the underlying I/O implementation or perhaps want to build a similar non-blocking process wrapper for another existing implementation, check out this project's source code and the previous blog posts linked above.

If you want to learn more about this project, make sure to check out the project homepage of [clue/reactphp-sqlite](https://github.com/clue/reactphp-sqlite). Its documentation describes common usage patterns as well as all the nifty details. While it is a relatively new project, it is considered stable and you're invited to also give it a try! If you like this project, spreading the word is much appreciated! If you have any feedback or just want to reach out and say hello, I'm happy to hear back and appreciate feedback! Use the comment section below or send a tweet to [@another_clue](https://twitter.com/another_clue).

> Did you know that I offer custom development services and issuing invoices for sponsorships of releases and for contributions? Contact me (@clue) for details.
