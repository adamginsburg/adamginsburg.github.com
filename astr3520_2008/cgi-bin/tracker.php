<?php
		$db = fopen('trackdb.txt','a');
		$thedate = date('Y/m/d H:i:s T');
		if(isset($_SERVER['argv'])) fwrite($db,$_SERVER['argv'].":	");
		if(isset($_GET['page']))  fwrite($db,$_GET['page'].":	");
		if(isset($_POST['page']))  fwrite($db,$_POST['page'].":	");
#		fwrite($db,$_SERVER['SCRIPT_FILENAME'].": ".$thedate."	".$_SERVER['HTTP_REFERER']."	".$_SERVER['HTTP_USER_AGENT'])."\n";
#		fwrite($db,"	 RemoteAddr:".$_SERVER['REMOTE_ADDR']." RemoteHost:".$_SERVER['REMOTE_HOST']."	\n");
		fclose($db)
		?>

