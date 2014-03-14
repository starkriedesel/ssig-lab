<?php
$_prefix = '/challenges/';

$_challenge_list = array(
  'basic/1' => 1,
  'basic/2' => 2,
  'basic/3' => 3,
  'basic/4' => 4,
  'basic/5' => 5,
);

// Define CHALLENGE_ID based on SCRIPT_NAME
if(!defined('CHALLENGE_ID')) {
  foreach($_challenge_list as $path=>$id) {
    if(strpos($_SERVER['SCRIPT_NAME'], $_prefix.$path) === 0) {
      define('CHALLENGE_ID', $id);
      break;
    }
  }
}