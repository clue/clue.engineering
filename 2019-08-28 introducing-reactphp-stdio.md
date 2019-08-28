Today, I'm happy to announce the stable `v2.3.0` release of [clue/reactphp-stdio](https://github.com/clue/reactphp-stdio), the event-driven and UTF-8 aware console input & output (STDIN, STDOUT) library for truly interactive CLI applications, built on top of [ReactPHP](https://reactphp.org/) 🎉

Once again, the version number and its [release history](https://github.com/clue/reactphp-stdio/releases) suggests this is not exactly a new project. In fact, this has been used in production for some projects for a few years already. So I guess it's about time to write an introductory blog post about this project and why I think @ReactPHP's design makes it a perfect fit.

## PHP is not only for the web

Traditionally, PHP is most frequently used to build web pages. Additionally, more and more people are getting accustomed to using PHP to build interactive CLI (command line interface) applications that run from the terminal instead of being accessed from a web browser. This often makes sense for maintenance commands that are run by priviledged users and development tools, that should be kept separate from the core application business logic (yet often share some of its domain logic).

With excellent CLI libraries such as [Symfony's Console Component](https://symfony.com/doc/current/components/console.html) and others, building solid and well-tested CLI tools is a breeze. The most common way to accept user input for such programs is either program arguments, environment variables or building an interactive dialog to ask for user input like this:

```terminal
$ php register-user-example.php
User Name?
> Alice
Email?
> alice@example.com
Created user Alice with ID 1
```

These kinds of applications are often said to follow an Input-Process-Output (IPO) model. Now if you want to learn more about how to build these traditional, interactive CLI application in PHP, I encourage you to check out the documentation linked above. What this post is more interested in is seeing how we can build truly interactive CLI applications that are driven by user interaction and allow you to respond to these events as soon as they happen.

## Event-driven console I/O

For some applications, this traditional Input-Process-Output (IPO) model is less applicable and makes a lot less sense. Think of any long-running CLI application, chat-like applications, read-eval-print-loop programs (REPL), log monitoring solution etc. These kinds of applications are often a perfect fit for an event-driven architecture where the program *reacts* to user input at any time instead of only *asking* for it at certain points. This means you give up some control over the program execution flow and instead let this flow be driven by events happening.

Getting started with this library isn't too hard. Just install it using `composer require clue/reactphp-stdio:^2.3` and use the following example code to react to any user input:

```php
$loop = React\EventLoop\Factory::create();
$stdio = new Stdio($loop);

$stdio->setPrompt('Input > ');

$stdio->on('data', function ($line) use ($stdio) {
    $line = rtrim($line, "\r\n");
    $stdio->write('Your input: ' . $line . PHP_EOL);

    if ($line === 'quit') {
        $stdio->end();
    }
});

$loop->run();
```

This very simple code snippet already allows you react to individual commands any time the user hits <kbd>enter</kbd>. For more sophisticated command parsing/routing, you may want to combine this with another library, such as [clue/arguments](https://github.com/clue/php-arguments) (more on that in a future blog post).

On top of this, you can use this library to control various aspects of your user interaction, such as history support using cursor keys, autocompletion using the <kbd>tab</kbd> key or even binding entirely new functions to individual key presses:

```php
$stdio->on('a', function () use ($stdio) {
     $stdio->addInput('ä');
});
```

Under the hood, this library does all the heavy lifting and takes care of applying the correct terminal settings and parsing terminal control code sequences to make this work. This allows you to focus just on your user interaction and how your program reacts to it, without requiring any special setup or extensions.

## Conclusions

There are plenty of use cases for building interactive command line tools. With this release of [clue/reactphp-stdio](https://github.com/clue/reactphp-stdio#quickstart-example), it becomes more feasible to build these tools with PHP. If a large fraction of your domain logic is written in PHP and/or you're already working with a team of PHP developers, you may want to give this project a try.

If you want to learn more about this project, make sure to check out the project homepage of [clue/reactphp-stdio](https://github.com/clue/reactphp-stdio). Its documentation describes common usage patterns as well as all the nifty details. It is considered stable (but not feature complete) and has been used in production for a few years already, so you're invited to also give it a try! If you like this project, spreading the word is much appreciated! If you have any feedback or just want to reach out and say hello, I'm happy to hear back and appreciate feedback! Use the comment section below or send a tweet to [@another_clue](https://twitter.com/another_clue).

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">Just released v2.3.0 of clue/reactphp-stdio, the event-driven and UTF-8 aware console input &amp; output (STDIN, STDOUT) library for truly interactive CLI applications with <a href="https://twitter.com/reactphp?ref_src=twsrc%5Etfw">@ReactPHP</a>. API cleaned up, consistent features, see blog post for motivation 🐘 <a href="https://twitter.com/hashtag/php?src=hash&amp;ref_src=twsrc%5Etfw">#php</a><a href="https://t.co/451zT4KqU6">https://t.co/451zT4KqU6</a></p>&mdash; Christian Lück (@another_clue) <a href="https://twitter.com/another_clue/status/1166685622523879424?ref_src=twsrc%5Etfw">August 28, 2019</a></blockquote>
