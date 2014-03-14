<?php
require 'include.php';

if(basic_login_check(CHALLENGE_FLAG, 'john'))
  die(rails_success_js_post());
else
  die('Login Failed');