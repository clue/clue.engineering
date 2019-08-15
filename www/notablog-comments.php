<?php

// notablog-comments.php (C) 2019 by @clue

// reject direct access with 403 (Forbidden)
if (strpos($_SERVER['REQUEST_URI'], $_SERVER['SCRIPT_NAME']) !== false || !isset($_GET['gist'])) {
    header(' ', false, 403);
    exit('bad request.');
}

// thank you Gistlog, you're awesome! <3
$gist = str_replace('https://gist.github.com/', '', $_GET['gist']);
$url = 'https://gistlog.co/' . $gist . '/comments.json';
$ret = @file_get_contents($url);
if ($ret === false) {
    header(' ', false, 500);
    die('internal server error, please try again later.');
}

header('Content-Type: application/json');
echo $ret;
