# WTFPHP
*Unfortunately, I didn't end up solving this one, but here's the notes I gathered on it*


- look at page source and see comment with following code snippet:
<?php
if (isset($_FILES['fileData'])) {
    if ($_FILES['fileData']['size'] > 1048576) {
        $errors = 'File size should be less than 1 MB';
    }
    if (empty($errors) == true) {
        $uploadedPath = "uploads/" . rand() . "." . explode(".", $_FILES['fileData']['name']) [1];
        move_uploaded_file($_FILES['fileData']['tmp_name'], $uploadedPath);
        echo "File uploaded successfully\n";
        echo '<p><a href=' . $uploadedPath . ' target="_blank">File</a></p>';
    } else {
        echo $errors;
    }
}
?>

- upload a few junk files and notice that the main page creates a link to the uploaded file but with a different name but the same extension
- make a sample .php file with just phpinfo() in it
- find list of disabled functions in phpinfo:
pcntl_alarm
pcntl_fork
pcntl_waitpid
pcntl_wait
pcntl_wifexited
pcntl_wifstopped
pcntl_wifsignaled
pcntl_wifcontinued
pcntl_wexitstatus
pcntl_wtermsig
pcntl_wstopsig
pcntl_signal
pcntl_signal_get_handler
pcntl_signal_dispatch
pcntl_get_last_error
pcntl_strerror
pcntl_sigprocmask
pcntl_sigwaitinfo
pcntl_sigtimedwait
pcntl_exec
pcntl_getpriority
pcntl_setpriority
pcntl_async_signals
error_log
link
symlink
syslog
ld
mail
exec
passthru
shell_exec
system
proc_open
popen
curl_exec
curl_multi_exec
parse_ini_file
show_source
highlight_file
file
fopen
fread
var_dump
readfile