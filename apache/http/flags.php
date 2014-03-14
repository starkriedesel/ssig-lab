<?php
// Rails Settings
$rails_server = 'http://10.0.0.5:8080';

// Redirect back to rails server
function rails_redirect($anchor='')
{
  global $rails_server;
  if(defined('CHALLENGE_ID'))
    header('location: '.$rails_server.'/challenges/'.CHALLENGE_ID.'#'.$anchor);
  else
    header('location: '.$rails_server.'/challengeGroups/#'.$anchor);
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

// DB Settings
$db_host = "localhost";
$db_user = "ssiglab";
$db_pass = "ssiglab";
$db_name = "ssiglab";
try {
  $db = new PDO("mysql:host=$db_host;dbname=$db_name", $db_user, $db_pass);
  $db->setAttribute( PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION );
} catch(PDOException $e) {
  die('Could not connect to database: '+$e);
}

// Get CHALLENGE_ID
require_once('challenge_list.php');

// Session start
session_start();

// Make sure to set CHALLENGE_ID in each file
if(!defined('CHALLENGE_ID'))
  die('CHALLENGE_ID not set');

// Check for rails authentication
if(isset($_POST['rails_nonce']))
{
  // Aquire lock on flag table, no monkey buisness while we authenticate
  try {
    $sth = $db->prepare('LOCK TABLES challenge_flags WRITE');
    $sth->execute();
  } catch(PDOException $e) {
    die('Database exception: '.$e);
  }

  // Get nonce from database
  try {
    $sth = $db->prepare('SELECT * FROM challenge_flags WHERE  nonce=?');
    $sth->execute(array($_POST['rails_nonce']));
    $assoc = $sth->fetch(PDO::FETCH_ASSOC);
  } catch(PDOException $e) {
    die('Database exception: '.$e);
  }

  // No flag row found (and sanity check), go back to rails for re-auth
  if(! $assoc || $assoc['nonce'] != $_POST['rails_nonce']) {
    rails_redirect('bad_nonce');
  }

  // Clear nonce from flag table so it cannot be replayed
  try {
    $sth = $db->prepare('UPDATE challenge_flags SET nonce=\'\' WHERE user_id=? AND challenge_id=?');
    $sth->execute(array($assoc['user_id'], $assoc['challenge_id']));
  } catch(PDOException $e) {
    die('Database exception: '.$e);
  }

  // Release Table Lock
  try {
    $sth = $db->prepare('UNLOCK TABLES');
    $sth->execute();
  } catch(PDOException $e) {
    die('Database exception: '.$e);
  }

  // If the session user_id is different from the flag's, shut'er down
  if(isset($_SESSION['rails_user_id']) && $assoc['user_id'] != $_SESSION['rails_user_id'])
  {
    session_destroy();
    rails_redirect('reauth');
  }

  // If the php challenge id is not the same as the flag's challenge id,
  //   try to get authed for the correct challenge
  if($assoc['challenge_id'] != CHALLENGE_ID)
    rails_redirect('bad_chal_id');
  
  // We are done, store the user info and flag
  $_SESSION['rails_user_id'] = $assoc['user_id'];
  if(!isset($_SESSION['flags']))
    $_SESSION['flags'] = array();
  $_SESSION['flags'][CHALLENGE_ID] = $assoc['value'];
  header('location: '.$_SERVER['PHP_SELF']);
  die;
}

// Check for flag in session
if(!isset($_SESSION['flags'], $_SESSION['flags'][CHALLENGE_ID]))
  rails_redirect('no_saved_flag');
define('CHALLENGE_FLAG', $_SESSION['flags'][CHALLENGE_ID]);

// Check if the session flag is current
try {
  $sth = $db->prepare('SELECT value FROM challenge_flags WHERE user_id=? AND challenge_id=?');
  $sth->execute(array($_SESSION['rails_user_id'], CHALLENGE_ID));
  $assoc = $sth->fetch(PDO::FETCH_ASSOC);
} catch(PDOException $e) {
  die('Database exception: '.$e);
}

// Redirect if the saved flag has expired
if(!$assoc || $assoc['value'] != CHALLENGE_FLAG)
  rails_redirect('flag_expired');

// Some helper functions for making challenges
require_once('helpers.php');
