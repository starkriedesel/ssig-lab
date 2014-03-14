<?php
  require '../../flags.php';

  if($_POST) {
    if(basic_login_check(substr(CHALLENGE_FLAG, 0, 4), 'john'))
      die(rails_success_js_post());
    else
      die('Login Failed');
  }
?>

<h1>Basic 4</h1>

<!--password.txt-->
<form method="post" action=".">
  <label>Username: </label><input type="text" name="username"><br>
  <label>Password: </label><input type="password" name="password"><br>
  <input type="submit" value="Login">
</form>