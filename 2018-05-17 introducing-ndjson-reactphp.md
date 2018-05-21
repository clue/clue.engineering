I'm happy to announce the very first stable release of [clue/reactphp-ndjson](https://github.com/clue/reactphp-ndjson) 🎉

> Streaming newline-delimited JSON ([NDJSON](http://ndjson.org)) parser and encoder for [ReactPHP](https://reactphp.org/).

Now that v1.0.0 has been tagged and released today, let's look into what NDJSON is, how it compares to other formats such as JSON, CSV etc. and how NDJSON can be used in PHP and @ReactPHP.

## Introduction to NDJSON

### NDJSON vs. JSON

To give you an idea of what NDJSON looks like, let's start with a really simple, (normal) JSON file, let's call this `users.json`:

```JSON
[
    {"id":1,"name":"Alice"},
    {"id":2,"name":"Bob"},
    {"id":3,"name":"Carol"}
]
```

This example uses an array of user objects where each user has a some arbitrary properties. This can easily be adjusted for many different use cases, such as storing for example products instead of users, assigning additional properties or having a significantly larger number of records.

In contract, let's look at the exact same example expressed as a simple NDJSON file, let's call this `users.ndjson`:

```JSON
{"id":1,"name":"Alice"}
{"id":2,"name":"Bob"}
{"id":3,"name":"Carol"}
```

If you understand JSON and you're now looking at this newline-delimited JSON for the first time, you should already know everything you need to know to understand NDJSON: As the name implies, this format essentially consists of individual lines where each individual line is any valid JSON text and each line is delimited with a newline character.

While each individual line is valid JSON, the complete file as a whole is technically no longer valid JSON, because it contains multiple JSON texts. This means that for example calling PHP's `json_decode()` on this input would fail, but more on that later.

The newline character at the end of each line allows for some really simple *framing* (detecting individual records). This can easily be used with line-oriented CLI tools, such as `grep` and others. What's important to note here is that because each line is a complete, valid JSON text, this implies that using "pretty printing" JSON (`JSON_PRETTY_PRINT`) is no longer possible. On the other hand, values containing newline characters (such as a description property) do not cause issues because each newline within a JSON string will be represented by a `\n` instead.

NDJSON files are great for transporting (uniform) records such as users or products or even structured log message events. You can edit NDJSON files in any text editor or use them in a streaming context where individual records should be processed. Unlike normal JSON files, adding a new log entry to this NDJSON file does not require modification of this files' structure (note there's no "outer array" to be modified). This makes it a perfect fit for a streaming context or a logging context where you want to append records at a later time.

For more details about the NDJSON specification, refer to its [project page](https://github.com/ndjson/ndjson-spec). There's hope this will become an [official RFC](https://github.com/ndjson/ndjson-spec/issues/21) eventually, but at the time of writing this it's not.

### NDJSON vs. CSV

One possible alternative to NDJSON would be comma separated values (CSV), as defined in [RFC 4180](https://tools.ietf.org/html/rfc4180). Now CSV is not exactly a new format and has been used in a large number of systems for decades, so let's see how this compares to NDJSON. The same example expressed as a CSV file could look like this, let's call this `users.csv`:

```CSV
id,name
1,Alice
2,Bob
3,Carol
```

CSV may look slightly simpler, but this simplicity comes at a price. CSV is limited to untyped, two-dimensional data, so there's no standard way of storing any nested structures or to differentiate a boolean value from a string or integer. Field names are sometimes used, sometimes they're not (application-dependant). Inconsistent handling for fields that contain separators such as `,` or spaces or even line breaks (think of URLS or user-provided descriptions) introduce additional complexity and its text encoding is usually undefined, Unicode (or UTF-8) is unlikely to be supported and CSV files often use ISO 8859-1 encoding or some variant (again application-dependant).

Despite its shortcomings CSV is widely used and this is unlikely to change any time soon. In particular, CSV is a very common export format for a lot of tools to interface with spreadsheet processors (such as Exel, Calc etc.). This means that CSV is often used for historial reasons and using CSV to store structured application data is usually not a good idea nowadays – but exporting to CSV for known applications is a very reasonable approach.

### NDJSON vs. JSON text sequences

A format somewhat similar to NDJSON is "JSON text sequences" as defined in [RFC 7464](https://tools.ietf.org/html/rfc7464). Among others, this is also used for "[GeoJSON](http://geojson.org/) Text Sequences" as defined in [RFC 8142](https://tools.ietf.org/html/rfc8142). The format differs mostly in that it uses the binary `RS` (*record separator*) binary ASCII/C0 code `\x1E` as a start indicator before each record.

The same example expressed as a JSON-sequence file could look like this, let's call this `users.json-seq`: 

```JSON
<RS>{"id":1,"name":"Alice"}
<RS>{"id":2,"name":"Bob"}
<RS>{"id":3,"name":"Carol"}
```

This article uses `<RS>` as a placeholder for the non-printable binary `RS` ASCII/C0 code. Other than that, the format looks almost identical to NDJSON, as you can see. Because the `RS` uniquely identifies the start of a new record, this format does indeed also allow "pretty printing" JSON:

```JSON
<RS>
{
    "id":1,
    "name":"Alice"
}
<RS>
{
    "id":2,
    "name":"Bob"
}
<RS>
{
    "id":3,
    "name":"Carol"
}
```

At this point you may wonder why this format exists when NDJSON exists (or the other way around). JSON text sequences are specifically designed for a streaming context. In particular, while its specification registers the new MIME media type `application/json-seq`, interestingly it does not define a file extension. In fact, you will probably not want to store and edit this format on a disk as the non-printable `RS` character may easily be garbled in common text editors.

If you use JSON text sequences in a streaming context, this will probably not be an issue and a single byte of overhead between each record is unlikely to be an issue either. Once you want to view this stream in a plaintext viewer or want to store this on disk, you may to consider using NDJSON as an alternative. At this point, one might argue that JSON text sequences provide little value over NDJSON and you may as well use NDJSON consistently.

### NDJSON vs. Concatenated JSON

One of the less commonly used alternatives to NDJSON is concatenated JSON, where each JSON text simply immediately follows without any separators at all. The same example expressed as a concatenated JSONe file could look like this, let's call this `users.cjson`: 

```JSON
{"id":1,"name":"Alice"}{"id":2,"name":"Bob"}{"id":3,"name":"Carol"}
```

Trying to interpret this example as a human requires only little more effort than NDJSON, because the end of each record is no longer as obvious. However, this can easily get way more complicated when a record contains nested data that contains sub-structures so that the resulting file may contain a large number of curly braces that do not necessarily terminate a record.

As a consequence, while generating concatenated JSON requires trivial effort, parsing this format actually requires significant effort. In fact, it requires implementing a context-aware parser to detect message framing so that message framing is no longer independant of actual message parsing. Fortunately, this is not a format you'll likely come across very often. Among others, this is used by the Docker daemon to send progress notifications only when using legacy HTTP/1.0.

If you have to deal with concatenated JSON in PHP, you may want to look into using [clue/json-stream](https://github.com/clue/php-json-stream). If you're in control over this format, I would suggest just adding a newline in between each record. Existing streaming parsers should be able to cope with this just fine as non-significant whitespace outside of JSON should be ignored. Also, this means that you've just turned this into standard NDJSON and can simply use the following processing logic :-)

## Parsing NDJSON with PHP

Now that we have an idea of what NDJSON looks like, let's look into how we can process our `users.ndjson` file in PHP. Because NDJSON is just a list of JSON texts, parsing NDJSON is actually somewhat trivial in PHP:

```php
$lines = file('users.ndjson');

foreach ($lines as $line) {
    $user = json_decode($line, true);
    echo 'hello ' . $user['name'] . PHP_EOL;
}
```

Similarly, appending a new user to the existing list is really simple:

```php
$user = [
    'id' => 4,
    'name' => 'Dave'
];

$line = json_encode($user) . "\n";

file_put_contents('users.ndjson', $line , FILE_APPEND);
```

If you've ever worked with JSON in PHP, then nothing of this should be really surprising to you. In fact, if you want to add NDJSON support to your existing projects, you probably won't even need a dedicated library for NDJSON.

The first example loads the whole NDJSON file into memory and then processes each record one after another. While this should work just fine for our small example, this approach is probably not viable once you have thousands of entries or want to use this in a streaming context where new records may come in at different times.

## Streaming NDJSON with ReactPHP

[ReactPHP](https://reactphp.org) is a low-level library for event-driven programming in PHP. In a nutshell, it allows you to run multiple I/O operations concurrently and "react" to incoming events.

Applying this to our above example, this means that we can use it to process our NDJSON file as a stream we can read from and then "react" to each record. For this to work, we'll install the new streaming NDJSON parser [clue/ndjson-reactphp](https://github.com/clue/reactphp-ndjson) like this:

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

While this code looks slightly more complicated than the previous example, this should still be pretty self-explanatory; it still simply prints a message for each user record.

Besides some additional boilerplate, the major difference to the first example is that this no longer imperatively loads everything into memory. It merely says that the given NDJSON file should be read and interpreted by the NDJSON decoder and we "react" to its `data `event.

This implies that this example actually supports files of arbitrary sizes as only small chunks will be processed in memory and ReactPHP takes care of invoking your event handlers as expected. An interesting side effect of this is that this may even be faster than the first example, because it can start processing records without having to wait for the whole file to be read into memory. In fact, this is way faster than many people would probably expect PHP to be. On my laptop this yields around 5 Gbit/s, so it's probably faster than your average network connection or persistent storage. (As always, don't trust some random stranger when it comes to performance – you're invited to run your own benchmarks and share what you've found.)

Arguably, this example is a bit "overkill" if you only want to stream a few records and note that this example uses `fopen()` for illustration purposes only. A truly async application should not use this, as the file system is inherently blocking. Luckily, streams are one of the core abstractions in ReactPHP, so that many different stream abstractions are available for a large number of use cases (TCP/IP connections, HTTP requests, databases etc., see also [stream documentation](https://reactphp.org/stream/) for more details). Having established these streaming concepts means that we can now use NDJSON in some pretty cool contexts…

### NDJSON for IPC

By now you should have an understanding that NDJSON is a very versatile format that can be very useful for a number of use cases. Instead of only using this to access local files, we may also use NDJSON as a very simple inter-process communication (IPC) protocol to pass any kind of structured messages between processes and build our own custom remote procedure call (RPC) mechanism. The following example is heavily inspired by [JSON-RPC](https://en.wikipedia.org/wiki/JSON-RPC). With a few more lines this could actually be adapted to implement its full specification, however we're trying to focus on the main idea of a simple RPC mechanism here fore the sake of brevity.

The full code to use NDJSON for as an IPC/RPC mechanism for process input and output could look something like this:

```php
$loop = React\EventLoop\Factory::create();

$in = new Clue\React\NDJson\Decoder(
    new React\Stream\ReadableResourceStream(STDIN, $loop),
    true
);
$out = new Clue\React\NDJson\Encoder(
    new React\Stream\WritableResourceStream(STDOUT, $loop)
);

$handler = new React\Stream\ThroughStream(function ($data) {
    if ($data['method'] === 'sum') {
        return [
            'result' => array_sum($data['params'])
        ];
    }
    
    return [
        'error' => 'Invalid method'
    ];
});

$in->pipe($handler)->pipe($out);

$loop->run();
```

Again, this code looks slightly more complicated than the previous example, but this should still be pretty self-explanatory; it reads from an NDJSON-based STDIN stream, processes each message and then sends back an NDJSON-based message to the STDOUT stream.

For example, you can now launch this script and send some JSON-RPC-like messages through STDIN and get back the results through its STDOUT stream:

```
$ php example.php
--> { "method": "sum", "params": [1, 2, 3, 4] }
<-- { "result": 10 }
```

While this example requires you to manually launch this script, it should show you everything you need to know to process structured JSON messages over STDIN/STDOUT streams. If you want to integrate this into an async application, you may also use ReactPHP'S [ChildProcess](https://reactphp.org/child-process/) component to programmatically spawn this process. For example, this allows you to offload CPU-intensive or blocking code to a separate process so that your main process can continue its non-blocking operation.

## Conclusions

Streaming JSON-based records or messages is a really powerful approach for a large number of use cases and by now I hope I could show you how newline-delimited JSON (NDJSON) is really simple, yet powerful, addition to this toolset.

[NDJSON](http://ndjson.org/) can be used to store multiple JSON records in a file to store any kind of (uniform) structured data, such as a list of user objects or log entries. It uses a simple newline character between each individual record and as such can be both used for efficient persistence and simple append-style operations. This also allows it to be used in a streaming context, such as a simple inter-process commmunication (IPC) protocol or for a remote procedure call (RPC) mechanism.

There are some valid criticisms against JSON and if human readability is not an issue for your use case, then there are some more efficient alternatives. Obviously, this also applies to NDJSON likewise. For many use cases this does not apply and JSON is a perfectly reasonable choice in this case. If you're processing multiple independent JSON objects, then NDJSON may be a good candidate.

If you want to learn more about this project, make sure to check out [clue/reactphp-ndjson](https://github.com/clue/reactphp-ndjson). If you like this project, spreading the word is much appreciated! If you have any feedback or just want to reach out and say hello, I'm happy to hear back and appreciate feedback! Use the comment section below or send a tweet to [@another_clue](https://twitter.com/another_clue).

<blockquote class="twitter-tweet" data-lang="de"><p lang="en" dir="ltr">Introducing streaming newline-delimited JSON (NDJSON) parser and encoder v1.0.0 for <a href="https://twitter.com/reactphp?ref_src=twsrc%5Etfw">@ReactPHP</a>! Efficient persistence for JSON-based log messages and streaming for simple IPC and RPC protocols 💪 <a href="https://twitter.com/hashtag/streaming?src=hash&amp;ref_src=twsrc%5Etfw">#streaming</a> <a href="https://twitter.com/hashtag/json?src=hash&amp;ref_src=twsrc%5Etfw">#json</a> <a href="https://twitter.com/hashtag/ndjson?src=hash&amp;ref_src=twsrc%5Etfw">#ndjson</a><a href="https://t.co/B9FT3VPvQ2">https://t.co/B9FT3VPvQ2</a></p>&mdash; Christian Lück (@another_clue) <a href="https://twitter.com/another_clue/status/997142697067601920?ref_src=twsrc%5Etfw">17. Mai 2018</a></blockquote>
