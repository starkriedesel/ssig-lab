<?php
  require 'include.php';
  header('X-Credentials: john:'.CHALLENGE_FLAG);
?>

<h1>Basic 3</h1>

<form method="post" action="login.php">
  <label>Username: </label><input type="text" name="username"><br>
  <label>Password: </label><input type="password" name="password"><br>
  <input type="submit" value="Login">
</form>