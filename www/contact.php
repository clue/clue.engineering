<?php

$email = filter_input(INPUT_POST, 'email', FILTER_VALIDATE_EMAIL);
$message = filter_input(INPUT_POST, 'message', FILTER_VALIDATE_REGEXP, ['options' => ['regexp' => '/^.{20,}$/su']]);

if (!is_string($email) || !is_string($message) || preg_match('/[\x00-\x08\x0b\x0c\x0e-\x1f]/', $message) || $_POST['url'] ?? '' !== '') {
    header(' ', true, 400);
    echo 'Invalid form submission, please check your data' . PHP_EOL;
    exit(1);
}

if (!preg_match('/clue|christian|lueck|lück/i', $message) && preg_match('/http(?:s?):\/\//i', $message)) {
    header(' ', true, 403);
    echo 'We\'re sorry, but our spam detection triggered on your message text. To avoid this, please go back and include my name in your message or send an email instead' . PHP_EOL;
    exit(1);
}

$subject = 'Contact Christian Lück';
$id = '<' . gmdate('YmdHis') . '.' . mt_rand() . '@clue.engineering>';
$ret = mail('hello@clue.engineering', '=?UTF-8?B?' . base64_encode($subject) . '?=', $message, "From: $email\r\nSender: hello@clue.engineering\r\nMessage-ID: $id\r\nContent-Type: text/plain; charset=utf-8");
assert($ret);

header('Location: contact#thanks');
