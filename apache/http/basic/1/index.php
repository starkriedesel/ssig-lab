<?php
  require '../../flags.php';

  if($_POST) {
    if(basic_login_check(CHALLENGE_FLAG, 'john'))
      die(rails_success_js_post());
    else
      die('Login Failed');
  }
?>

<h1>Basic 1</h1>

<!--john:<?=CHALLENGE_FLAG?>-->
<form method="post" action=".">
  <label>Username: </label><input type="text" name="username"><br>
  <label>Password: </label><input type="password" name="password"><br>
  <input type="submit" value="Login">
</form>