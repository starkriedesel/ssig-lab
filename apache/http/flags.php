<?php
// Rails Settings
$rails_server = 'http://10.0.0.5:8080';

// Redirect back to rails server
function rails_redirect()
{
  global $rails_server;
  if(defined('CHALLENGE_ID'))
    header('location: '.$rails_server.'/challenges/'.CHALLENGE_ID);
  else
    header('location: '.$rails_server.'/challengeGroups/');
  die;
}

// Return a JQuery API tag
function jquery_api()
{
  return '<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"></script>';
}

// Post the success flag back to the rails server
function rails_success_js_post()
{
    global $rails_server;
    $flag = CHALLENGE_FLAG;
    $rails_challenge_id = CHALLENGE_ID;
    return jquery_api() . <<<EOF
        <h1>Submitting Flag</h1>
        <form method="post" id="flag_submit" action="$rails_server/challenges/$rails_challenge_id/complete">
            <input type="hidden" name="flag" value="$flag">
        </form>
        <script>$("#flag_submit").submit();</script>
EOF;
}

function basic_login_check($password=null, $username=null)
{
  if($password === null)
  {
    if(defined('CHALLENGE_FLAG'))
      $password == CHALLENGE_FLAG;
    else
      return false;
  }
  if(! isset($_REQUEST['password']) || ($username!==null && ! isset($_REQUEST['username'])))
    return false;
  if($_REQUEST['password'] != $password || ($username!=null && ! $_REQUEST['username'] == $username))
    return false;
  return true;
}

// DB Settings
$db_host = "localhost";
$db_user = "ssiglab";
$db_pass = "ssiglab";
$db_name = "ssiglab";
$db_port = 3306;
$db_handle = mysqli_connect($db_host,$db_user,$db_pass,$db_name, $db_port) or die('Could not connect to MySQLi');

// Session start
session_start();

// Make sure to set CHALLENGE_ID in each file
if(!defined('CHALLENGE_ID'))
  rails_redirect();

// Check for rails authentication
if(isset($_POST['rails_user_id'], $_POST['rails_challenge_id'], $_POST['rails_nonce']))
{
  // If the php challenge id is not the same as the given challenge id,
  //   try to get authed for the correct challenge
  if($_POST['rails_challenge_id'] != CHALLENGE_ID)
    rails_redirect();
  
  // If the stored user_id is different from the one that is authenticating, shut'er down
  if(isset($_SESSION['rails_user_id']) && $_POST['rails_user_id'] != $_SESSION['rails_user_id'])
  {
    session_destroy();
    header('location: '.$rails_server.'#reauth');
    die;
  }
  
  $res = mysqli_query($db_handle, 'SELECT * FROM challenge_flags WHERE user_id='.$_POST['rails_user_id'].' AND challenge_id='.$_POST['rails_challenge_id']);
  $assoc = mysqli_fetch_assoc($res);
  
  // If no matching record, shut'er down
  if(! $assoc || $assoc['nonce'] != $_POST['rails_nonce'])
  {
    session_destroy();
    header('location: '.$rails_server.'#bad_nonce');
    die;
  }
  
  // Otherwise, store the user info and flag
  $_SESSION['rails_user_id'] = $_POST['rails_user_id'];
  if(!isset($_SESSION['flags']))
    $_SESSION['flags'] = array();
  $_SESSION['flags'][CHALLENGE_ID] = $assoc['value'];
  header('location: '.$_SERVER['PHP_SELF']);
  die;
}

// Check for flag in session
if(!isset($_SESSION['flags'], $_SESSION['flags'][CHALLENGE_ID]))
  rails_redirect();
define('CHALLENGE_FLAG', $_SESSION['flags'][CHALLENGE_ID]);

// Check if the session flag is current
$res = mysqli_query($db_handle, 'SELECT * FROM challenge_flags WHERE user_id='.$_SESSION['rails_user_id'].' AND challenge_id='.CHALLENGE_ID);
$assoc = mysqli_fetch_assoc(($res));
if(!$assoc || $assoc['value'] != CHALLENGE_FLAG)
  rails_redirect();