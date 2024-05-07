#!/bin/bash

#run with base url argument like "http://clue.localhost" or "https://user:pass@clue.example"
base=${1:-http://clue.localhost}
redir=$(echo $base | sed "s,://.*@,://,g")

n=0
curl() {
    out=$($(which curl) "$@" 2>&1);
}
match() {
    n=$[$n+1]
    echo "$out" | grep "$@" >/dev/null && echo -n . || \
        (echo ""; echo "Error in test $n: Unable to \"grep $@\" this output:"; echo "$out"; exit 1) || exit 1
}

curl -v $base/
match "HTTP/.* 200"
match -iP "Content-Type: text/html[;\r\n]"

curl -v $base/index.html
match "HTTP/.* 302"
match -iP "Location: $redir/[\r\n]"

curl -v $base/index.html/
match "HTTP/.* 404"

curl -v $base/index
match "HTTP/.* 404"

curl -v $base/blog
match "HTTP/.* 200"
match -iP "Content-Type: text/html[;\r\n]"

curl -v $base/blog.html
match "HTTP/.* 302"
match -iP "Location: $redir/blog[\r\n]"

curl -v $base/blog/
match "HTTP/.* 302"
match -iP "Location: $redir/blog[\r\n]"

curl -v $base/2019
match "HTTP/.* 302"
match -iP "Location: $redir/blog#2019[\r\n]"

curl -v $base/2019/
match "HTTP/.* 302"
match -iP "Location: $redir/blog#2019[\r\n]"

curl -v $base/2000
match "HTTP/.* 404"

curl -v $base/2000/
match "HTTP/.* 404"

curl -v $base/2018/hello-world
match "HTTP/.* 200"
match -iP "Content-Type: text/html[;\r\n]"

curl -v $base/2018/hello-world/
match "HTTP/.* 302"
match -iP "Location: $redir/2018/hello-world[\r\n]"

curl -v $base/contact
match "HTTP/.* 200"
match -iP "Content-Type: text/html[;\r\n]"

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
match -iP "Location: $redir/contact[\r\n]"

curl -v $base/contact.php
match "HTTP/.* 302"
match -iP "Location: $redir/contact[\r\n]"

curl -v $base/contact/
match "HTTP/.* 302"
match -iP "Location: $redir/contact[\r\n]"

echo "OK ($n)"
