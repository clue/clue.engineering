Today, I'm happy to announce the `v2.3.0` release of [clue/reactphp-redis](https://github.com/clue/reactphp-redis), the async [Redis](https://redis.io/) database client built on top of [ReactPHP](https://reactphp.org/) 🎉

Once again, the version number and its [release history](https://github.com/clue/reactphp-redis/releases) suggests this is not exactly a new project. In fact, this has been used in production in a larger number of projects for a few years already. So I guess it's about time to write an introductory blog post about this project, what Redis is all about and why I think @ReactPHP's design makes it a perfect fit.

## About Redis

[Redis](https://redis.io/) is an open source, advanced, in-memory key-value database. It offers a set of simple, atomic operations in order to work with its primitive data types. Its lightweight design and fast operation makes it an ideal candidate for modern application stacks.

This library provides you a simple API to work with your Redis database from within PHP. It enables you to set and query its data or use its PubSub topics to react to incoming events.

```php
$loop = React\EventLoop\Factory::create();
$factory = new Factory($loop);
$client = $factory->createLazyClient('localhost');

$client->set('greeting', 'Hello world');
$client->append('greeting', '!');

$client->get('greeting')->then(function ($greeting) {
    // Hello world!
    echo $greeting . PHP_EOL;
});

$client->incr('invocation')->then(function ($n) {
    echo 'This is invocation #' . $n . PHP_EOL;
});

// end connection once all pending requests have been resolved
$client->end();

$loop->run();
```

Even if you've never worked with Redis or ReactPHP's async APIs, you should should be able to understand what's going on in this example. It uses some simple Redis commands to store and dump a greeting message and will report how often you've run this example code.

One of the major new features in this version of this library is the support for lazy connections as highlighted in the above example. Similar to the recently introduced [lazy MySQL connections](https://www.lueck.tv/2018/introducing-reactphp-mysql-lazy-connections), this allows you to enqueue new commands while the underlying connection may still be pending.

If you've ever worked with Redis or ReactPHP's async APIs before, you may appreciate how each method call on the client matches exactly one Redis command. Its Promise-based API allows you to easily invoke any number of commands that will be pipelined to your Redis database automatically and you can react to the commands results you care about. One of the nice properties of Redis is the fact that it provides some very simple commands to work with its in-memory data structures. Combined with ReactPHP's event-driven architecture and this library's efficient network protocol implementation, this can be used to process thousands of requests per second.

## PubSub

Perhaps more importantly than accessing Redis' data structures, this library is commonly used to efficiently transport messages using Redis' [Pub/Sub](https://redis.io/topics/pubsub) (Publish/Subscribe) channels. For instance, this can be used to distribute single messages to a larger number of subscribers (think horizontal scaling for chat-like applications) or as an efficient message transport in distributed systems (microservice architecture).

The [`PUBLISH` command](https://redis.io/commands/publish) can be used to send a message to all clients currently subscribed to a given channel:

```php
$channel = 'user.register';
$message = json_encode(array('id' => 10));
$client->publish($channel, $message);
```

The [`SUBSCRIBE` command](https://redis.io/commands/subscribe) can be used to subscribe to any number of channels and then receive incoming PubSub `message` events:

```php
$client->subscribe('user.register');
$client->subscribe('user.join');
$client->subscribe('user.leave');

$client->on('message', function ($channel, $payload) {
    // pubsub message received on given $channel
    var_dump($channel, json_decode($payload));
});
```

Similarly, the [`PSUBSCRIBE` command](https://redis.io/commands/psubscribe) can be used to subscribe to all channels matching a given pattern and then receive all incoming PubSub messages with the `pmessage` event:

```php
$pattern = 'user.*';
$client->psubscribe($pattern);

$client->on('pmessage', function ($pattern, $channel, $payload) {
    // pubsub message received matching given $pattern
    var_dump($channel, json_decode($payload));
});
```

Once you're in a subscribed state, Redis no longer allows executing any other commands on the same client connection. This is commonly worked around by simply creating a second client connection and dedicating one client connection solely for PubSub subscriptions and the other for all other commands.

When using the lazy client connection as given above and the underlying connection is lost due to a network interruption, this library will now automatically emit `unsubscribe` and `punsubscribe` events as appropriate. This now makes it much easier to build long-running applications and either quit with an error message in this case or simply invoke the respective `SUBSCRIBE` commands again in order to restore any subscriptions for more fault-tolerant applications.

## Conclusions

[Redis](https://redis.io/) is an efficient and versatile database. Its lightweight design and fast operation makes it an ideal candidate for modern application stacks. Combined with ReactPHP's event-driven architecture and this library's efficient network protocol implementation, this can be used to efficiently process a large quantity of messages in a number of different use cases. Whether you're using it as a more traditial data store, as a caching layer or a message distribution system, we've got you covered!

If you want to learn more about this project, make sure to check out the project homepage of [clue/reactphp-redis](https://github.com/clue/reactphp-redis). Its documentation describes common usage patterns as well as all the nifty details. It is considered stable and feature complete and has been used in production for a few years already, so you're invited to also give it a try! If you like this project, spreading the word is much appreciated! If you have any feedback or just want to reach out and say hello, I'm happy to hear back and appreciate feedback! Use the comment section below or send a tweet to [@another_clue](https://twitter.com/another_clue).

<blockquote class="twitter-tweet" data-lang="de"><p lang="en" dir="ltr">Just released clue/reactphp-redis v2.3.0, the async <a href="https://twitter.com/hashtag/redis?src=hash&amp;ref_src=twsrc%5Etfw">#redis</a> database client for <a href="https://twitter.com/reactphp?ref_src=twsrc%5Etfw">@ReactPHP</a> 🎉 This version features improved <a href="https://twitter.com/hashtag/PubSub?src=hash&amp;ref_src=twsrc%5Etfw">#PubSub</a> messaging, lazy database connections and much more, get it while it&#39;s hot! 🐘🔥 <a href="https://twitter.com/hashtag/async?src=hash&amp;ref_src=twsrc%5Etfw">#async</a> <a href="https://twitter.com/hashtag/php?src=hash&amp;ref_src=twsrc%5Etfw">#php</a> <a href="https://twitter.com/hashtag/nosql?src=hash&amp;ref_src=twsrc%5Etfw">#nosql</a> <a href="https://t.co/YEprkZcDk5">https://t.co/YEprkZcDk5</a></p>&mdash; Christian Lück (@another_clue) <a href="https://twitter.com/another_clue/status/1105188582170476544?ref_src=twsrc%5Etfw">11. März 2019</a></blockquote>

Once again I'd like to thank [@geertvanbommel](https://github.com/geertvanbommel), a fellow software architect specializing in database batch processing and API development, for sponsoring large parts of this development! 🎉 Thanks to sponsors like this, who understand the importance of open source development, I can justify spending time and focus on open source development instead of traditional paid work. If you follow my posts more regularly, I'm sure you'll recall his name. And if you plan to follow my future posts, I'm sure there are more exiting announcements to follow in the future…

> Did you know that I offer custom development services and issuing invoices for sponsorships of releases and for contributions? Contact me (@clue) for details.
