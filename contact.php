<?php

$name = filter_input(INPUT_POST, 'name', FILTER_VALIDATE_REGEXP, ['options' => ['regexp' => '/^[^\x00-\x1f]{2,200}$/u']]);
$email = filter_input(INPUT_POST, 'email', FILTER_VALIDATE_EMAIL);
$company = filter_input(INPUT_POST, 'company', FILTER_VALIDATE_REGEXP, ['options' => ['regexp' => '/^[^\x00-\x1f]{0,200}$/u']]);
$budget = filter_input(INPUT_POST, 'budget', FILTER_VALIDATE_REGEXP, ['options' => ['regexp' => '/^[^\x00-\x1f]{2,200}$/u']]);
$message = filter_input(INPUT_POST, 'message', FILTER_VALIDATE_REGEXP, ['options' => ['regexp' => '/^[^\x00-\x08\x0b\x0c\x0e-\x1f]{20,}$/u']]);

if (!is_string($name) || !is_string($email) || !is_string($company) || !is_string($budget) || !is_string($message) || isset($email[200]) || $_POST['url'] ?? '' !== '') {
    header(' ', true, 400);
    echo 'Invalid form submission, please check your data' . PHP_EOL;

    exit(1);
}

$body = 'Name:' . "\n" . $name . "\n\n";
if (($company ?? '') !== '') {
    $body .= 'Company:' . "\n" . $company . "\n\n";
}
$body .= 'Budget: ' . "\n" . $budget . "\n\n";
$body .= 'Message:' . "\n" . $message;

$subject = 'Contact Christian Lück';
$id = '<' . gmdate('YmdHis') . '.' . mt_rand() . '@clue.engineering>';
$ret = mail('hello@clue.engineering', '=?UTF-8?B?' . base64_encode($subject) . '?=', $body, "From: $email\r\nSender: hello@clue.engineering\r\nMessage-ID: $id\r\nContent-Type: text/plain; charset=utf-8");
if ($ret === false) {
    header(' ', true, 500);
    echo 'Unable to send mail, please contact hello@clue.engineering directly' . PHP_EOL;

    exit(1);
}

header('Location: contact#thanks');
