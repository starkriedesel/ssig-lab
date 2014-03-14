<?php
  require 'include.php';
?>

<h1>Basic 1</h1>

<!--john:<?=CHALLENGE_FLAG?>-->
<form method="post" action="login.php">
  <label>Username: </label><input type="text" name="username"><br>
  <label>Password: </label><input type="password" name="password"><br>
  <input type="submit" value="Login">
</form>