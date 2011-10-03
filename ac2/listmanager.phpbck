 <?php

$username = "casacoffee";
$password = "casa";
?>

<html>
<head><title>Astro-coffee article list handler</title>
<meta name="keywords" content="astro-ph, arxiv, astronomy, boulder, coffee" />
<meta name="author" content="Boulder Astronomy" />
<link rel="stylesheet" type="text/css" href="style.css" />
</head>

<body>

 <?php
$pname = 'papers';

$fp = @fopen($pname, "r"); 
$loadcontent = fread($fp, filesize($pname)); 
$lines = file($pname) or die("can`t open file: ".$pname." for reading");
$count = count($lines);
$loadcontent = htmlspecialchars($loadcontent); 
fclose($fp); 
?>

<h2>Astro-coffee article list handler  </h2>

Current contents of the article list file:

  <form name="form" method="post" action="<?php echo $_SERVER['php_SELF'];?>">
    <textarea style="text-align: left; padding: 0px; overflow: auto; border: 3px groove; font-size: 12px" name="savecontent" cols="80" rows="<?=($count+3);?>" wrap="OFF"><?=$loadcontent?></textarea>
    <br>
    Username: <input type="text" name="txtUsername" />
    Password: <input type="password" name="txtPassword" />
    <input type="submit" name="save_file" value="submit and save">

  </form>
  <br><hr>
<?php


  if (!isset($_POST['save_file'])) {
    
    print "<p>Use this to clean out old entries from the database.  ";
    print "Edit the file as you see fit, and enter the appropriate ";
    print "username and password.  Then, click 'submit and save.'</p>";
    print "<p>Return to the <a href='astro_coffee.php'>main page</a></p>";
  }

elseif ((($_POST['txtUsername']== $username and $_POST['txtPassword']== $password)) and (isset($_POST['save_file']))) { 
      if (isset($_POST["save_file"])){
	echo 'you set the save file<br>';
	echo 'the new contents are:<br>';
	echo $_POST["savecontent"];

	$fp2 = @fopen($pname, "w") or die("can`t open file: ".$pname); 
	fwrite($fp2, $_POST["savecontent"]);
	fclose($fp2);
	$loadcontent = $_POST["savecontent"];
	echo '<META HTTP-EQUIV=Refresh CONTENT="2">';

      }
}
else
  {
    echo "<h3>No way, dude(tte).</h3>";
    echo "<p>  You didn't enter the correct username/password!<br>";
    echo "Reloading the page in 5 seconds, to let ";
    echo 'you try again... </p>';
    echo '<META HTTP-EQUIV=Refresh CONTENT="5">';
  }

?>
</body>
</html> 
