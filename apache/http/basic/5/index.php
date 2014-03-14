<?php
  require_once '../../flags.php';
  require_once 'password.txt';

  if($_POST) {
    if(basic_login_check($subset_flag, 'john'))
      die(rails_success_js_post());
    else
      die('Login Failed');
  }
?>

<h1>Basic 5</h1>

<!--password.txt-->
<form method="post" action=".">
  <label>Username: </label><input type="text" name="username"><br>
  <label>Password: </label><input type="password" name="password"><br>
  <input type="submit" value="Login">
</form>