#!/bin/bash

# run from the repository root with base url argument like "http://clue.localhost" or "https://user:pass@clue.example"
base=${1:-http://clue.localhost/}
base=${base%/}

# base url with any userinfo removed
redir=$(echo $base | sed "s,://.*@,://,g")

n=0
curl() {
    out=$(command curl "$@" 2>&1 | sed 's/\r$//');
}
match() {
    n=$((n+1))
    echo "$out" | grep "$@" >/dev/null && echo -n . || \
        (echo ""; echo "Error in test $n: Unable to \"grep $@\" this output:"; echo "$out"; exit 1) || exit 1
}

curl -v $base/
match "HTTP/.* 200"
match -iE "Content-Type: text/html(;.*)?$"
match -iE "Cache-Control: max-age=86400$"
match -F "<link href=\"src/landing-page.$(sha1sum www/src/landing-page.v2.css | cut -c-7).css\" rel=\"stylesheet\">"
match -F "<link href=\"src/tailwind.$(sha1sum www/src/tailwind.min.css | cut -c-7).css\" rel=\"stylesheet\">"

curl -v $base/index.html
match "HTTP/.* 302"
match -iE "Location: $redir/$"

curl -v $base/index.html/
match "HTTP/.* 404"

curl -v $base/index
match "HTTP/.* 404"

curl -v $base/blog
match "HTTP/.* 200"
match -iE "Content-Type: text/html(;.*)?$"
match -iE "Cache-Control: max-age=86400$"
match -F "<script async src=\"src/app.$(sha1sum www/src/app.v2.js | cut -c-7).js\"></script>"

curl -v $base/blog.html
match "HTTP/.* 302"
match -iE "Location: $redir/blog$"

curl -v $base/blog/
match "HTTP/.* 302"
match -iE "Location: $redir/blog$"

curl -v $base/2019
match "HTTP/.* 302"
match -iE "Location: $redir/blog#2019$"

curl -v $base/2019/
match "HTTP/.* 302"
match -iE "Location: $redir/blog#2019$"

curl -v $base/2000
match "HTTP/.* 404"

curl -v $base/2000/
match "HTTP/.* 404"

curl -v $base/2018/hello-world
match "HTTP/.* 200"
match -iE "Content-Type: text/html(;.*)?$"

curl -v $base/2018/hello-world/
match "HTTP/.* 302"
match -iE "Location: $redir/2018/hello-world$"

curl -v $base/contact
match "HTTP/.* 200"
match -iE "Content-Type: text/html(;.*)?$"

curl -v $base/contact -X POST
match "HTTP/.* 400"

curl -v $base/contact --data name=A --data email=alice@example.com --data company=ACME --data budget=None --data message="Let's get in touch!"
match "HTTP/.* 400" # name length

curl -v $base/contact --data name=Alice --data email=alice --data company=ACME --data budget=None --data message="Let's get in touch!"
match "HTTP/.* 400" # email invalid

curl -v $base/contact --data name=Alice --data email=alice@example.com --data company=ACME --data budget=A --data message="Let's get in touch!"
match "HTTP/.* 400" # budget invalid

# curl -v $base/contact --data name=Alice --data email=alice@example.com --data company= --data budget=Yes --data message="Let's get in touch!!"
# match "HTTP/.* 302" # valid without company

# curl -v $base/contact --data name=Alice --data email=alice@example.com --data company=ACME --data budget=Yes --data message="Let's get in touch!!"
# match "HTTP/.* 302" # valid with company

curl -v $base/contact.html
match "HTTP/.* 302"
match -iE "Location: $redir/contact$"

curl -v $base/contact.php
match "HTTP/.* 302"
match -iE "Location: $redir/contact$"

curl -v $base/contact/
match "HTTP/.* 302"
match -iE "Location: $redir/contact$"

curl -v $base/posts.atom
match "HTTP/.* 200"
match -iE "Content-Type: application/atom\+xml$"
match -iE "Cache-Control: max-age=86400$"

curl -v $base/src/tailwind.$(sha1sum www/src/tailwind.min.css | cut -c-7).css
match "HTTP/.* 200"
match -iE "Content-Type: text/css$"
match -iE "Cache-Control: max-age=31536000, immutable$"

curl -v $base/src/landing-page.$(sha1sum www/src/landing-page.v2.css | cut -c-7).css
match "HTTP/.* 200"
match -iE "Content-Type: text/css$"
match -iE "Cache-Control: max-age=31536000, immutable$"

curl -v $base/src/app.$(sha1sum www/src/app.v2.js | cut -c-7).js
match "HTTP/.* 200"
match -iE "Content-Type: (text|application)/javascript$"
match -iE "Cache-Control: max-age=31536000, immutable$"

curl -v $base/src/tailwind.min.css
match "HTTP/.* 404"

curl -v $base/src/landing-page.v2.css
match "HTTP/.* 404"

curl -v $base/src/app.v2.js
match "HTTP/.* 404"

echo "OK ($n)"
