<?php

function basic_login_check($password=null, $username=null, $submitted_password=null, $submitted_username=null)
{
  if($password === null)
  {
    if(defined('CHALLENGE_FLAG'))
      $password == CHALLENGE_FLAG;
    else
      return false;
  }

  if($submitted_username === null && isset($_REQUEST['username']))
    $submitted_username = $_REQUEST['username'];

  if($submitted_password === null && isset($_REQUEST['password']))
    $submitted_password = $_REQUEST['password'];

  if($submitted_password === null || ($username !== null && $submitted_username === null))
    return false;

  if($submitted_password != $password || ($username != null && $submitted_username != $username))
    return false;

  return true;
}