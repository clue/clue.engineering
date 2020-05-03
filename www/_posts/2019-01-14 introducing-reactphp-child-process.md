---
title: Introducing event-driven child process for ReactPHP
legacy_id: 2019/introducing-reactphp-child-process
tags:
  - introducing-reactphp
  - reactphp
  - release
  - process
  - ipc
author:
  - Christian Lück
---

Today, we're very happy to announce the immediate availability of the next major beta release of [reactphp/child-process](https://github.com/reactphp/child-process), the event-driven library for executing child processes with [ReactPHP](https://reactphp.org/). 🎉

**ReactPHP ❤️ Windows**

As the main feature of this `v0.6.0` release, this library now has limited Windows support and supports passing custom pipes and file descriptors to the child process. Let's look into why we think this is a major milestone for this project and how this can be used to spawn a child process to offload a blocking process in a non-blocking way with ReactPHP.

This post aims more for the "why" instead of "what" has changed. This release involves a few minor BC breaks, but we expect that most consumers of this package will actually not be affected. If you're upgrading from a previous version of this project, you may want to take a look at the [changelog](https://github.com/reactphp/child-process/releases/tag/v0.6.0) describing all the changes in greater detail. Alright, so let's dive right in.

## Fork off!

[ReactPHP's vast ecosystem](https://github.com/reactphp/react/wiki/Users) features a large number of existing implementations for pretty much any widespread protocol and database system out there, including [HTTP](https://clue.engineering/2018/introducing-reactphp-buzz), [MySQL](https://clue.engineering/2018/introducing-reactphp-mysql-lazy-connections) and many others. But when it comes to the less widespread applications, there's always a chance that a non-blocking implementation may not be avaialble for ReactPHP. This is particularly common when it comes to the more enterprisey, proprietary applications that haven't been updated for non-blocking application setups.

For this blog post, let's assume we want to send a "ping" (or `IMCP ECHO REQUEST`) to a host to check if it is "up" and running. While we may of course also create a non-blocking ICMP implementation (more on that in a later blog post), it's often plain easier to just use what already exists and just spawn a helper program ("forking"). After installing the ChildProcess component with `composer require react/child-process:^0.6`, this example could look something like this:

```php
$loop = React\EventLoop\Factory::create();

$process = new React\ChildProcess\Process('ping example.com');
$process->start($loop);

$process->stdout->on('data', function ($chunk) {
    echo $chunk;
});

$process->on('exit', function($exitCode, $termSignal) {
    echo 'Process exited with code ' . $exitCode . PHP_EOL;
});

$loop->run();
```

This example will simply dump all the process output from the `ping` command and will eventually report the exit code which tells us if this execution was successful or not. This should work on all Unix-like platforms, but due to platform constraints requires some changes to support Windows. Unfortunately, PHP does not allow accessing standard I/O pipes without blocking, so we can now explicitly omit any I/O pipes and just access its exit code like this:

```php
$loop = React\EventLoop\Factory::create();

$process = new React\ChildProcess\Process('ping example.com', null, null, array());
$process->start($loop);

$process->on('exit', function($exitCode, $termSignal) {
    echo 'Process exited with code ' . $exitCode . PHP_EOL;
});

$loop->run();
```

While we agree that this may not cover 100% of possible use cases, we stil believe that this on its own is already a powerful feature that fulfills *many* of the use cases. And *because* we agree that this doesn't cover all possible use cases, we've gone the extra mile and have described a number of possible workarounds in our extensive [documentation](https://github.com/reactphp/child-process#windows-compatibility) and examples.

## Conclusions

The ChildProcess component allows easily offloading blocking applications to a separate process running in the background without blocking our main application. It now allows spawning child processes on any platform, finally also including Windows! This makes [reactphp/child-process](https://github.com/reactphp/child-process) an important piece of the puzzle of bringing ReactPHP to the masses. If you're running a child process on Windows, you're invited to give one of the known workarounds a go and see how it works out in your use case. Based on your feedback, we're planning to build the upcoming version with these built-in, so that common use cases work out of the box without requiring a special handling in the future.

If you want to learn more about this project, make sure to head over to [reactphp/child-process](https://github.com/reactphp/child-process) and make sure to let us know what you think about this! ❤️ Let's celebrate this release 🎉

<blockquote class="twitter-tweet" data-lang="de"><p lang="en" dir="ltr">New major ChildProcess beta release is exciting news again! Offload blocking applications without blocking main application on any platform with <a href="https://twitter.com/reactphp?ref_src=twsrc%5Etfw">@ReactPHP</a> 🐘💪 <a href="https://twitter.com/hashtag/async?src=hash&amp;ref_src=twsrc%5Etfw">#async</a> <a href="https://twitter.com/hashtag/php?src=hash&amp;ref_src=twsrc%5Etfw">#php</a><br><br>Also, <a href="https://twitter.com/reactphp?ref_src=twsrc%5Etfw">@ReactPHP</a> ❤️ <a href="https://twitter.com/Windows?ref_src=twsrc%5Etfw">@Windows</a>. <a href="https://t.co/0wjuR5Oqw9">https://t.co/0wjuR5Oqw9</a></p>&mdash; Christian Lück (@another_clue) <a href="https://twitter.com/another_clue/status/1084867632908722177?ref_src=twsrc%5Etfw">14. Januar 2019</a></blockquote>
