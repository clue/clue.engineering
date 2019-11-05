---
title: Introducing event-driven Docker Engine API client for ReactPHP
social_image: https://user-images.githubusercontent.com/776829/65258290-efbbf180-db02-11e9-90c7-4f3ee532e2df.jpg
tags:
  - introducing-reactphp
  - reactphp
  - release
  - docker
  - container
  - process
---

![animal-animal-photography-blue-water-831084](https://user-images.githubusercontent.com/776829/65258290-efbbf180-db02-11e9-90c7-4f3ee532e2df.jpg)
<!-- https://www.pexels.com/photo/photography-of-whale-tail-on-water-surface-831084/ -->

Today, I'm happy to announce the first stable `v1.0.0` release of [clue/reactphp-docker](https://github.com/clue/reactphp-docker), the async client library for event-driven access to the [Docker Engine API](https://docs.docker.com/develop/sdk/), built on top of [ReactPHP](https://reactphp.org/) 🎉

Once again, don't be fooled by the version number: Its [release history](https://github.com/clue/reactphp-docker/releases) suggests this is not exactly a new project. In fact, this is one of the projects that got me hooked on ReactPHP's event-driven execution model a while ago and I think it's about time to share some insights and surprising benchmarking results!

## About Docker

I'd be surprised if you haven't heard about Docker yet, so I'll make it quick: [Docker](https://www.docker.com/) is a popular open source platform to run and share applications within isolated, lightweight containers. If that doesn't make sense to you, you can think of it as lightweight VMs - except it's not using VMs technically.

Docker comes with a set of handy CLI tools to run and manage containers and more. This allows you to easily run applications that would otherwise require special environments (think of large, complex applications, database servers etc.) straight from the command line without any complex setup.

What makes Docker special internally, is that it builds on top of a Client-Server-Model. This means that every time you use the `docker` command, it will actually send a command to the Docker Daemon that will execute the containers and send back any output. This is where our client comes into play!

## Event-driven Docker API

By leveraging Docker's existing API with our [async HTTP client](https://clue.engineering/2018/introducing-reactphp-buzz), we can take advantage of the exact same functionality from within an event-driven PHP application. Among others, this means we can start containers, watch their streaming log output, react to interesting events, download images and much more.

[clue/reactphp-docker](https://github.com/clue/reactphp-docker) provides a lightweight abstraction to access all these functions in an async API. For example, let's take a look at streaming the container log output as it happens:

```php
$loop = React\EventLoop\Factory::create();
$client = new Clue\React\Docker\Client($loop);

$stream = $client->containerLogsStream($container, true);
$stream->on('data', function ($data) {
    echo $data;
});

$loop->run();
```

Even if you've never worked with ReactPHP's streaming APIs, you should be able to understand what's going on in this simple example: It simply dumps each chunk of log output for the given container to the console output.

The above snippet only aims to give you an idea of how this lightweight API can be used. If you want to learn more about the methods provided by the API, you can take a look at the provided API documentation or at the official [Docker Engine API documentation](https://docs.docker.com/develop/sdk/).

## Benchmarking

Now I've promised some interesting benchmarking results, so let's look into this. If we can stream log output from a running container like above, we can also measure *how fast* we can receive this output. For this, this library comes with a benchmarking example that dumps a bunch of bytes of output and then measures how long it takes to receive them. Here's one of the runs on my laptop:

```bash
$ php examples/benchmark-exec.php container dd if=/dev/zero bs=1M count=4k
Received 4294967296 bytes in 1.8s => 2355.1 MB/s
```

*(insert surprised emoji here!)* To be perfectly clear, this is now what I would have expected the first time I executed this benchmark. This suggests that this library can process several gigabytes per second and may in fact outperform the Docker client and seems to be limited only by the Docker Engine implementation. Instead of going into too many details here, you're encouraged to re-run the benchmarks yourself and see for yourself.

The key takeaway here is: *PHP is faster than you probably thought*.

Just think about it this way: Do you have a use case where you're writing more than 16 Gbit/s, which is faster than your average network connection or common SSDs these days?

## Conclusions

[Docker](https://www.docker.com/) is a popular open source platform to run and share applications within isolated, lightweight containers. If you haven't used it yet, you should give it a try, seriously. With the release of [clue/reactphp-docker](https://github.com/clue/reactphp-docker), you can now access its functionality right from within PHP. Its benchmarking performance suggests this is unlikely to be a limitation any time soon, so consider giving it a try.

If you want to learn more about this project, make sure to check out the project homepage of [clue/reactphp-docker](https://github.com/clue/reactphp-docker). Its documentation describes common usage patterns as well as all the nifty details. It is considered stable (but not feature complete) and has been used in some projects for a few years already and you're invited to also give it a try! If you like this project, spreading the word is much appreciated! If you have any feedback or just want to reach out and say hello, I'm happy to hear back and appreciate feedback! Use the comment section below or send a tweet to [@another_clue](https://twitter.com/another_clue).

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">Just released v1.0.0 of clue/reactphp-docker, giving you event-driven access to the Docker Engine API with <a href="https://twitter.com/hashtag/PHP?src=hash&amp;ref_src=twsrc%5Etfw">#PHP</a>. Run containers and efficiently stream Gigabytes of data, <a href="https://twitter.com/reactphp?ref_src=twsrc%5Etfw">@ReactPHP</a> and <a href="https://twitter.com/Docker?ref_src=twsrc%5Etfw">@Docker</a> are a perfect match 🐳❤️🐘<a href="https://t.co/7MdekMoHvn">https://t.co/7MdekMoHvn</a></p>&mdash; Christian Lück (@another_clue) <a href="https://twitter.com/another_clue/status/1174707566129102848?ref_src=twsrc%5Etfw">September 19, 2019</a></blockquote>
