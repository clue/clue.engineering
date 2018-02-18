"Pushing the limits with [ReactPHP](https://reactphp.org) – why ReactPHP is awesome and why you should care" has by now become what one could consider  my signature talk. In this post I'm trying to give a short overview what this talk is all about, why I think this is a very relevant topic and how I got into all of this.

<img src="https://speakerd.s3.amazonaws.com/presentations/168db7d59e8e467e85cd6a39e6b1389e/slide_0.jpg" />

*Given that this blog post contains a bit of my personal background and how I got into public speaking, this blog post turned out to be bit lengthy. I realize that this may not be of interest to everybody, so I've added some annotations to things you may want to skip.*

## Prolog

In case you haven't already seen this talk, here's the latest teaser description (abstract):

*It's 2018 and times have changed – yet PHP is still most often associated with your average product catalog or blogging platform. In this talk you will learn that PHP's huge ecosystem has way more to offer and PHP is not inferior at all to its evil cousin Node.js.*

*You will learn about the core concepts of async PHP and why you too should care about ReactPHP being a real thing. The talk has a strong focus on sparking the idea that PHP can be way faster and more versatile than you probably thought. Bring along an open mind and through lots of examples and demos learn why what sounds crazy at first might soon be a valuable addition in your toolbox.*

As you can see, the talk intentionally has less focus on describing *how* things work, but a rather strong focus on getting a certain point across: PHP is a very powerful and useful tool even for todays requirements and todays projects! PHP may not be perfect, but it gets the job done for a large number of use cases – and probably for way more use cases than you may have thought at first. The landscape that PHP is used in has changed significantly in the last ~20 years or so – and so has PHP.

If this sounds interesting to you (maybe because you feel that you've somehow reached PHP limits) or if you feel that I'm completely [wrong](https://xkcd.com/386/) (maybe because you still think PHP is one huge pile of [`U+1F4A9`](http://graphemica.com/%F0%9F%92%A9)), I either *encourage* or *challenge* you to check out my talk below.

## Background

*This section contains a bit about my personal background and how I got into this. This may help understanding why I think ReactPHP is important. If you only care about the talk, you may as well skip this chapter.*

In one way or another, I usually start my talk with a short introduction about myself:

*Hello, my name Christian "[@another_clue](https://twitter.com/another_clue)" Lück. Nowadays, people mostly recognize me as a maintainer of [ReactPHP](https://reactphp.org), public speaker and Freelance Software Engineering Consultant.*

Given that nowadays I'm one of the maintainers of @ReactPHP, it may sound *natural* that I speak about one of my *pet projects*. However, back when I started giving talks about this, I was just a regular contributor and not really in control of the project direction. Here's a bit of the story behind this.

I've been involved with open source software development both in my professional and personal life for more than a decade and a half. Some time back in 2012 I was looking for a way to abstract network I/O for what would eventually become [clue/socks-react](https://github.com/clue/php-socks-react). Somehow I stumbled upon @ReactPHP which was still in its infancy and just had its first v0.1.0 tagged.

After incorporating ReactPHP into my project, I quickly realized that ReactPHP's design promised to change what PHP application development could look like. I've started filing a number of smaller patches to add missing functionally and eventually created a number of projects around this concept, some which were later *promoted* to become official ReactPHP components, some of which still exist as independent projects today.

While working on my Masters thesis in 2013 I had the great opportunity to find a mentoring professor who supported me in suggesting my preferred topic. This allowed me to devote a significant amount of time and effort to conceive and build a project with a number of open source projects which I've been involved with ever since, in particular ReactPHP. While this project was a great success and is still in use today, this was created in cooperation with a local company and unfortunately can't be released due to an NDA (more on that in a later post, promised). After finishing my Masters Degree in Information Systems Engineering (M.Eng.) in late 2013, I've continued working as a Software Engineering and Development Coach for said local company and was responsible for helping break down complex problems in a security critical software domain and to provide reliable, maintainable solutions for decades to come.

I had created a number of (what I still think are some really interesting) open source projects and tried to maintain these projects as time permitted. I regularly filed contributions to related projects and occasionally received some contributions for my projects, but being in full-time employment I ultimately felt I couldn't really effort spending the time they deserved. I continued to help maintain these projects and slowly but steadily we made some significant improvements to ReactPHP's project structure in 2014 and 2015. In late 2015, I was approached by @mre and @andygrunwald who asked if I would be interested in giving a talk at the local user group @webengdus (was called @phpugdus back then). After visiting their incredible(!) user group a few times, we settled on May 2016 for my talk.

Now if you still haven't skipped this section and you're still reading this, then you may have an understanding of why I am passionate about this talk. While working out some specifics for the talk and discussing some options with @mre and @andygrunwald we quickly agreed that my talk should be exactly about this: conveying this passion and raising awareness *why ReactPHP is awesome*.

In fact, this also made me realize that it's about time for the next step in my career: At around the same time I finally decided to quit my full-time job in order to focus on some thrilling things ahead: Becoming a Freelance Software Engineering Consultant – an idea I've been thinking about for a longer time. Now this wasn't a rash decision and I'm totally convinced that this was the right thing to do, as it allowed me to focus on some really thrilling things in 2016, 2017 and beyond – but more on that in another blog post… :-)

## The talk

Now if you've followed through here, then you may have an idea what this talk is about and you may understand why I am passionate about this topic. I try to transport this to the audience of this talk (you!) by regularly adjusting the talk to the specific audience, local circumstances and recent events and try to have a good interaction with the audience by encouraging engaging in the demos. I encourage you to check out the talk if you haven't already. While I think transporting the basic idea works through just the slides, I would argue that transporting much of the passion works best in person or by at least watching the recording.

**Here, you can find the [latest slides](https://speakerdeck.com/clue/pushing-the-limits-with-reactphp-scotlandphp17) (including PDF download) and the [latest recording](https://www.youtube.com/watch?v=L9W8aqWgL3M).**

<details>
  <summary>Expand details about all past talk dates…</summary>

What follows is a hopefully complete listing of all talk dates and details that I could gather about each event. This list may seem messy – and it probably *is*. I realize that a number of these links may not work anymore, but these are the links that used to work back when I originally gave the talk. If you find a link is outdated or missing and you know a better link, please reach out and I'm happy to update this list. Thank you!

* 2016-05-12 **@webengdus** (was @phpugdus) (Düsseldorf)
  * Usergroup talk ~2h (first public talk)
  * [Info](https://www.meetup.com/de-DE/Web-Engineering-Duesseldorf/events/230807092/)
  * [Slides](https://speakerdeck.com/clue/pushing-the-limits-of-php-with-react-php)
* 2016-09-03 **@t3dd** (Nürnberg)
  * Highlight talk + workshop (first public conference talk)
  * [Slides](https://speakerdeck.com/clue/t3dd16-pushing-the-limits-with-react-php)
  * [Recording](https://www.youtube.com/watch?v=giCIozOefy0)
* 2016-09-18 **@phpunconf** (Hamburg)
  * Unconf talk split into two talks with ~40min each (Examples and Concepts)
  * [Info](https://bootev.github.io/2016-phpunconference-schedule/sunday.html)
  * [Recording](https://www.youtube.com/watch?v=-5ZdGUvOqx4)
* 2016-10-18 **@phpugms** (Münster)
  * Usergroup talk
  * [Info](https://www.meetup.com/de-DE/phpugms/events/232608916/)
* 2016-11-10 **@phpruhr** (Dortmund)
  * Conference talk + spontanious hands-on workshop
  * [Info](https://2016.php.ruhr/session/pushing-the-limits-with-react-php/)
* 2017-06-01 **@phpconference** (Berlin)
  * Conference talk
  * [~~Info~~](https://phpconference.com)
  * [Slides](https://speakerdeck.com/clue/pushing-the-limits-of-php-with-reactphp-why-reactphp-is-awesome-and-why-you-should-care-ipc17)
* 2017-06-30 **@dpcon** (Amsterdam)
  * Conference talk
  * [~~Info~~](https://www.phpconference.nl/speakers#christian-l%C3%BCck)
  * [Slides](https://speakerdeck.com/clue/pushing-the-limits-with-reactphp-dpc17)
  * [Recording](https://www.youtube.com/watch?v=fQxxm4vD8Ok)
  * [Rating](https://joind.in/event/dutch-php-conference-2017/pushing-the-limits-of-php-with-react-php---why-react-php-is-awesome-and-why-you-should-care)
* 2017-09-22 **@phpdd** (Dresden)
  * Conference talk
  * [~~Info~~](http://phpug-dresden.org/en/phpdd17/schedule.html)
  * [Slides](https://speakerdeck.com/clue/pushing-the-limits-with-reactphp-phpdd17)
  * [Recording](https://www.youtube.com/watch?v=L9W8aqWgL3M)
  * [Rating](https://joind.in/event/php-developer-day-2017/pushing-the-limits-with-reactphp)
* 2017-10-06 **@phpwebdevcgn** and **@phpugcgn** (Köln)
  * Usergroup talk
  * [Info](https://www.meetup.com/de-DE/PHP-Web-Entwicklung-Meetup-Koln/events/242404744/)
* 2017-10-26 **@phpugmrn** (Mannheim)
  * Usergroup talk
  * [Info](https://www.meetup.com/de-DE/PHPUG-Rhein-Neckar/events/237289198/)
  * [Rating](https://joind.in/event/phpugmrn-0517/pushing-the-limits-of-php-with-reactphp)
* 2017-11-04 **@scotlandphp** (Edinburgh)
  * Conference talk
  * [Info](https://conference.scotlandphp.co.uk/speakers#luck)
  * [Slides](https://speakerdeck.com/clue/pushing-the-limits-with-reactphp-scotlandphp17)
  * [Rating](https://joind.in/event/scotlandphp-2017/pushing-the-limits-of-php-with-reactphp)
* 2018-01-24 **@phpugmunich** (München)
  * Usergroup talk + hands-on workshop ("getting started with ReactPHP")
  * [Info](https://www.meetup.com/de-DE/phpugmunich/events/gprpwmyxcbgc/)
* 2018-01-31 **@phpugka** (Karlsruhe)
  * Usergroup talk
  * [Info](https://www.meetup.com/de-DE/PHP-Usergroup-Karlsruhe/events/246619958/)

</details>

## Epilog

The talk concludes with a few key points:

* **PHP is way faster and more versatile than many people think**
* **ReactPHP is a real deal and here to stay**
* **Consider using ReactPHP if doing network I/O**

I've given a number of variations of this talk with these conclusions and have received some very interesting, positive feedback about this in the past ~2 years. Reading through the many reviews of my talk, I particularly liked reading how **exciting and inspiring** this talk was to a number of people. A lot of people seem to agree and share this idea and plenty of people show interest in ReactPHP. [Installation statistics](https://packagist.org/packages/react/) suggest that this trend continues to go on.

Of course, a number of people have also raised some (very valid!) criticism about some aspects of this talk. The talk heavily relies on live demos and examples and these things tend to break occasionally. I always have a backup plan at hand and while things tend to work just fine most of the times, I nowadays tend to warn people upfront to not cause any frustration in case things don't work on first try. One thing that also keeps coming up is that some people wish for more technical details. I realize that this is a valid concern, but it's my understanding that due to time constraints for regular talks I would much rather spend time on getting the basic idea across instead of getting lost in details. That being said, I agree that there's a time and place for these details and I'm looking forward to creating a talk specifically about just that in the future!

## Looking forward

Personally, I thoroughly enjoy giving these talks and entering discussions about these concepts. What's particularly interesting is seeing how different people have different use cases for ReactPHP and face entirely different issues with adopting these core concepts to their particular use case. I believe that becoming a Freelance Software Engineering Consultant was totally the right thing to do, as this has allowed me to focus on helping a number of projects getting started with ReactPHP and I'm looking forward to continue doing so in the future as ReactPHP and its ecosystem matures!

However, as much as I enjoy giving what has now become my signature talk, I will very likely step down a bit in this regard in the future and do not plan to actively promote and push this specific talk anymore. Instead, I would like to focus on helping people "getting started with ReactPHP" and will be preparing some fresh content for a future talk and upcoming hands-on workshops. That being said, if you want me to speak at your local event (user group or conference), reach out and I'm sure we can arrange this! Additionally, I also give talks specifically tailored during my freelance work, so reach out.

If you like the talk, spreading the word is much appreciated! If you have an feedback or just want to reach out and say hello, I'm happy to hear back and appreciate feedback! Use the comment section below or send a tweet to [@another_clue](https://twitter.com/another_clue).

Cheers! 🍻