<?php
  require '../../flags.php';

  if($_POST) {
    if(basic_login_check(CHALLENGE_FLAG))
      die(rails_success_js_post());
    else
      die('Login Failed');
  }
?>

<h1>Basic 4</h1>

<!--password.txt-->
<form method="post" action=".">
  <label>Password: </label><input type="password" name="password"><br>
  <input type="submit" value="Login">
</form>
