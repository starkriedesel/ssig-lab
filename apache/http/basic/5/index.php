<?php
  require_once '../../flags.php';
  require_once 'password.txt';

  if($_POST) {
    if(basic_login_check($subset_flag))
      die(rails_success_js_post());
    else
      die('Login Failed');
  }
?>

<h1>Basic 5</h1>

<!--password.txt-->
<form method="post" action=".">
  <label>Password: </label><input type="password" name="password"><br>
  <input type="submit" value="Login">
</form>
