<?php
  require '../../flags.php';

  if($_GET) {
    if(basic_login_check(CHALLENGE_FLAG, 'john'))
      die(rails_success_js_post());
    else
      die('Login Failed');
  } else {
    echo jquery_api();
  }
?>

<script language="javascript">
  function check_pass()
  {
    username = $('#username').val();
    password = $('#password').val();
    if(username == "john" && password == "<?=CHALLENGE_FLAG?>")
      window.location = './?username='+username+'&password='+password;
    else
      alert("Incorrect username/password");
  }
</script>

<h1>Basic 2</h1>

<label>Username: </label><input type="text" id="username"><br>
<label>Password: </label><input type="password" id="password"><br>
<input type="button" value="Login" onclick="check_pass(this)">