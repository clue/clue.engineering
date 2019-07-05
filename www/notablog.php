<?php

// notablog.php (C) 2018 by @clue

// reject direct access with 403 (Forbidden)
if (strpos($_SERVER['REQUEST_URI'], $_SERVER['SCRIPT_NAME']) !== false || !isset($_GET['gist'])) {
    header(' ', false, 403);
    exit('bad request.');
}

// thank you Gistlog, you're awesome! <3
$gist = str_replace('https://gist.github.com/', '', $_GET['gist']);
$url = 'https://gistlog.co/' . $gist;
$ret = @file_get_contents($url);
if ($ret === false) {
    header(' ', false, 500);
    die('internal server error, please try again later.');
}

// remove unneeded navigation bar
$ret = preg_replace('#<nav.*?>.*?</nav>#is', '<br />', $ret);

// replace all root links with text
$ret = preg_replace('#<a href="?/[^>]*>(.*?)</a>#is', '$1', $ret);

// simplify title attribute
$ret = preg_replace('#<title.*?>([^\|]+).*?</title>#i', '<title>$1</title>', $ret);

// gistlog comment form is broken, so replace with simple link instead
// replace textarea[placeholder] with "<a href>{placeholder}</a>"
$ret = preg_replace(
    '#<form.*?<textarea.*?placeholder="(.*?)".*?>.*?</form>#is',
    '<a href="https://gist.github.com/' . $gist . '#comments" class="block w-full p-4 mb-8 border-solid border border-grey">$1</a>',
    $ret
);

// rewrite og:url to canonical target
$ret = str_replace(
    $url,
    (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? 'https' : 'http') . '://' . $_SERVER['HTTP_HOST'] . $_SERVER['REQUEST_URI'],
    $ret
);

echo $ret;
