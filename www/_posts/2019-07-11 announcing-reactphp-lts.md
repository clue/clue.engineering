---
title: Announcing full stable ReactPHP LTS release
---

![ReactPHP – 7 years](https://user-images.githubusercontent.com/776829/61060544-39dd7400-a3ea-11e9-8184-50a680564518.png)

Exactly seven years ago, 11th July 2012, the very first [v0.1.0 release](https://reactphp.org/changelog.html#eventloop-010-2012-07-11) of ReactPHP was tagged. On [last year's anniversary](https://clue.engineering/2018/announcing-reactphp-lts) we took the chance to releases the first set of stable components for ReactPHP's main components. Today, we're thrilled to announce the immediate availability of the very first stable v1.0.0 release of the remaining main components of any ReactPHP application:

* [react/cache v1.0.0](https://reactphp.org/changelog.html#cache-100-2019-07-11)
* [react/dns v1.0.0](https://reactphp.org/changelog.html#dns-100-2019-07-11)

ReactPHP consists of a set of individual [components](https://reactphp.org/#core-components). This means that instead of installing something like a "ReactPHP framework", you actually can pick only the components that you need. With the above release announcement, this now means that when installing ReactPHP's main components, you now get full longer-term support (LTS) releases for all main components!

**Happy birthday ReactPHP!** 🎉

## LTS

> For some time already, ReactPHP has been production ready and is battle-tested with millions of installations from all kinds of projects around the world. With these new stable LTS releases now following [SemVer](https://semver.org/), we'd like to emphasize just this. We plan to support all long-term support (LTS) releases for at least 24 months, so you have a rock-solid foundation to build on top of. – [Last year's release announcement](https://clue.engineering/2018/announcing-reactphp-lts).

We're extending this LTS promise (no pun intended) for at least another 24 months for all main components as described above. This means that these LTS releases continue being a stable base for you to build on top of. The release series will be supported for at least 24 months, so you can safely update these main components, getting all the upcoming features without having to worry about BC breaks.

## Stable meta package

As an alternative to this component based approach, we also provide `react/react` as a meta package that will install all stable components at once. Installing this is only recommended for quick prototyping, as the list of stable components may change over time. In other words, this meta package does not contain any source code and instead only consists of links to all our main components, see also our [list of components](https://reactphp.org/#core-components) for more details.

## Looking forward

We've put some very significant effort into stabilizing ReactPHP's main components and streamlining and documenting existing behavior. On top of this, we'planning to build some exciting things, so don't worry: development doesn't stop here!

In the coming weeks and months, this allows us to focus our development efforts on our HTTP client and server components and bring in some long anticipated features: Among others, we've prepared some changes that will bring 200% performance improvements, will provide support for reusing connections (keep-alive) and will provide an outlook for HTTP/2 support soon! More on that in a later post, for now let's first celebrate this major milestone! 🎉🎉🎉

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">Happy birthday <a href="https://twitter.com/reactphp?ref_src=twsrc%5Etfw">@ReactPHP</a>! 🎉 Today, seven years after the first v0.1.0, we&#39;re thrilled to announce the immediate availability of the full stable v1.0.0 release with long-term support for all <a href="https://twitter.com/reactphp?ref_src=twsrc%5Etfw">@ReactPHP</a> main components! 🎉 <a href="https://twitter.com/hashtag/php?src=hash&amp;ref_src=twsrc%5Etfw">#php</a> <a href="https://twitter.com/hashtag/lts?src=hash&amp;ref_src=twsrc%5Etfw">#lts</a> <a href="https://twitter.com/hashtag/release?src=hash&amp;ref_src=twsrc%5Etfw">#release</a> <a href="https://t.co/ssvxWsMJUY">https://t.co/ssvxWsMJUY</a></p>&mdash; Christian Lück (@another_clue) <a href="https://twitter.com/another_clue/status/1149355062336077825?ref_src=twsrc%5Etfw">July 11, 2019</a></blockquote>
