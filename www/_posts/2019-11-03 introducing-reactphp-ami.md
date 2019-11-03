---
title: Introducing event-driven Asterisk Manager Interface (AMI) for ReactPHP
social_image: https://user-images.githubusercontent.com/776829/67948024-23e7ff00-fbe5-11e9-9662-fb8f0ca16edc.jpg
---

![black-and-white-black-and-white-chairs-315638](https://user-images.githubusercontent.com/776829/67948024-23e7ff00-fbe5-11e9-9662-fb8f0ca16edc.jpg)
<!-- https://www.pexels.com/photo/chairs-on-table-against-window-315638/ -->

This week, I'm happy to announce the first stable `v1.0.0` release of [clue/reactphp-ami](https://github.com/clue/reactphp-ami), the streaming, event-driven access to the Asterisk Manager Interface (AMI), built on top of [ReactPHP](https://reactphp.org/) 🎉

Once again, don't be fooled by the version number: Its [release history](https://github.com/clue/reactphp-ami/releases) suggests this is not exactly a new project. In fact, this is one of the projects that got me hooked on ReactPHP's event-driven execution model a while ago and one of the first ReactPHP-based projects that I've used in a production environment. So I guess it's about time to write an introductory blog post about this project and why I think ReactPHP's design makes it a perfect fit.

## About Asterisk

The [Asterisk PBX](https://www.asterisk.org/) is a popular open-source telephony solution that offers a wide range of telephony features for both VoIP and traditional PSTN networks. Asterisk powers IP PBX systems, VoIP gateways, conference servers and other custom solutions. It is used by small businesses, large businesses, call centers, carriers and government agencies, worldwide.

Asterisk's configuration is quite complex and feature-rich. In a gist, Asterisk is configured using a static dialplan configuration to define how incoming and outgoing phone calls are routed to which telephone (number or "extension"). On top of this, it also supports dynamic scripts to create custom behavior (like dynamic voice menus) using <abbrev title="Asterisk Gateway Interface">AGI</abbrev> scripts (which is left up for a follow-up blog post) and monitoring and controlling the current state using <abbrev title="Asterisk Manager Interface">AMI</abbrev> scripts as described below.

## Async AMI Actions

The Asterisk Manager Interface (AMI) provides access to a number of [actions](https://wiki.asterisk.org/wiki/display/AST/Asterisk+17+AMI+Actions) to execute on your Asterisk server. Among others, this can be used to check what phone calls are currently ongoing, end an active call, dial a new number, send a text message (SMS) and much more.

[clue/reactphp-ami](https://github.com/clue/reactphp-ami) provides a lightweight abstraction to access these functions in an async API. For example, let's take a look at the current SIP peers connected to your Asterisk server:

```php
$loop = React\EventLoop\Factory::create();
$factory = new Clue\React\Ami\Factory($loop);

$factory->createClient('user:secret@localhost')->then(function (Clue\React\Ami\Client $client) {
    echo 'Client connected' . PHP_EOL;

    $sender = new Clue\React\Ami\ActionSender($client);
    $sender->sipPeers()->then(function (Clue\React\Ami\Protocol\Collection $collection) {
        $peers = $collection->getEntryEvents();
        echo 'Found ' . count($peers) . ' peers' . PHP_EOL;
    });
});

$loop->run();
```

Even if you've never worked with Asterisk or ReactPHP's async APIs, you should should be able to understand what's going on in this example. It uses a simple AMI action retrieve all current SIP peers and dumps the number of SIP peers to the console.

If you've ever worked with AMI or ReactPHP's async APIs before, you may appreciate how each method call on the `ActionSender` matches exactly one AMI action. Its Promise-based API allows you to easily invoke any number of actions that will be pipelined to your Asterisk PBX automatically and you can react to the action results you care about. For more details, you may also want to check out the provided documentation or the list of [AMI actions](https://wiki.asterisk.org/wiki/display/AST/Asterisk+17+AMI+Actions) provided by Asterisk.

## Event-driven AMI events

Besides executing actions on your Asterisk server, the Asterisk Manager Interface (AMI) also allows you to monitor the current state and receive a number of [events](https://wiki.asterisk.org/wiki/display/AST/Asterisk+17+AMI+Events) whenever something interesting happens. Among others, this can be used to get an instant notification when a new phone call comes in, somebody picks up their phone and much more.

Again, [clue/reactphp-ami](https://github.com/clue/reactphp-ami) provides a lightweight abstraction to access these events using a simple event-driven API. For example, let's take a look at all the events that are reported by your Asterisk server:

```php
$loop = React\EventLoop\Factory::create();
$factory = new Clue\React\Ami\Factory($loop);

$factory->createClient('user:secret@localhost')->then(function (Clue\React\Ami\Client $client) {
    echo 'Client connected' . PHP_EOL;

    $sender = new Clue\React\Ami\ActionSender($client);
    $sender->events(true);

    $client->on('close', function() {
        echo 'Connection closed' . PHP_EOL;
    });

    $client->on('event', function (Clue\React\Ami\Protocol\Event $event) {
        echo 'Event: ' . $event->getName() . ': ' . json_encode($event->getFields()) . PHP_EOL;
    });
});

$loop->run();
```

Even if you've never worked with ReactPHP's event-driven APIs, you should be able to understand what's going on in this simple example: It simply dumps each incoming event name and its fields whenever a new event is received. This simple example keeps running as long as the connection to your Asterisk server is active and will keep reporting all events as they happen.

The above snippet only aims to give you an idea of how this lightweight API can be used. In a more realistic example you may want to filter certain events (such as all incoming phone calls only) and use this information to build your own live dashboard application. If you want to learn more about the events exposed by this API, you can take a look at the provided API documentation or at the official list of [AMI events](https://wiki.asterisk.org/wiki/display/AST/Asterisk+17+AMI+Events).

## Conclusions

The [Asterisk PBX](https://www.asterisk.org/) is a popular open-source telephony solution that offers a wide range of telephony features for both VoIP and traditional PSTN networks. It powers a large variety of installations of custom IP PBX systems and more. With this stable release of [clue/reactphp-ami](https://github.com/clue/reactphp-ami), you can use its actions and events from within PHP to build customized solutions.

If you want to learn more about this project, make sure to check out the project homepage of [clue/reactphp-ami](https://github.com/clue/reactphp-ami). Its documentation describes common usage patterns as well as all the nifty details. It is considered stable and feature complete and has been used in production projects for a few years already and you're invited to also give it a try! If you like this project, spreading the word is much appreciated! If you have any feedback or just want to reach out and say hello, I'm happy to hear back and appreciate feedback! Use the comment section below or send a tweet to [@another_clue](https://twitter.com/another_clue).
