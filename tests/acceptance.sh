#!/bin/bash

#run with base url argument like "http://clue.test" or "https://user:pass@clue.test"
base=${1:-http://clue.test}
redir=$(echo $base | sed "s,://.*@,://,g")
echo -n "Testing $redir"

n=0
match() {
    n=$[$n+1]
    echo "$out" | grep "$@" >/dev/null && echo -n . || \
        (echo ""; echo "Error in test $n: Unable to \"grep $@\" this output:"; echo "$out"; exit 1) || exit 1
}

out=$(curl -v $base/ 2>&1) &&           match "HTTP/.* 200"
out=$(curl -v $base/index.html 2>&1) && match -i "Location: $redir"
out=$(curl -v $base/index 2>&1) &&      match "HTTP/.* 404"

out=$(curl -v $base/blog 2>&1) &&       match "HTTP/.* 200"
out=$(curl -v $base/blog.html 2>&1) &&  match -i "Location: $redir/blog"
out=$(curl -v $base/blog/ 2>&1) &&      match -i "Location: $redir/blog"

out=$(curl -v $base/2019 2>&1) &&   match -i "Location: $redir/blog#2019"
out=$(curl -v $base/2019/ 2>&1) &&  match -i "Location: $redir/blog#2019"
out=$(curl -v $base/2000 2>&1) &&   match "HTTP/.* 404"
out=$(curl -v $base/2000/ 2>&1) &&  match "HTTP/.* 404"

out=$(curl -v $base/2018/hello-world 2>&1) &&   match "HTTP/.* 200"
out=$(curl -v $base/2018/hello-world/ 2>&1) &&  match -i "Location: $redir/2018/hello-world"

out=$(curl -v $base/contact 2>&1) &&            match "HTTP/.* 200"
out=$(curl -v $base/contact -X POST 2>&1) &&    match "HTTP/.* 400"
out=$(curl -v $base/contact --data email=foo@example.com --data message="hello http://example.com" 2>&1) &&  match "HTTP/.* 403"
out=$(curl -v $base/contact --data email=foo@example.com --data message="hello https://example.com" 2>&1) && match "HTTP/.* 403"
# out=$(curl -v $base/contact --data email=foo@example.com --data message="For Christian: http://example.com" 2>&1) && match "HTTP/.* 302"
out=$(curl -v $base/contact.html 2>&1) &&       match -i "Location: $redir/contact"
out=$(curl -v $base/contact.php 2>&1) &&        match -i "Location: $redir/contact"
out=$(curl -v $base/contact/ 2>&1) &&           match -i "Location: $redir/contact"

echo "OK ($n)"
