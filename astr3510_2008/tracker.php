<?php
#		echo "Tracking!";
#		echo "Version: " . phpversion();
#		$isset = date_default_timezone_set('America/Denver');
#		echo "Timezone is set...".$isset;
if ( is_writeable('trackdb.htm'))
{
		$db = fopen('trackdb.htm','a');
#		echo $db;
		$thedate = date('Y/m/d H:i:s T');
#		echo $thedate;
                fwrite($db,"<br>".$page.": ".$thedate." <a href=\"".
                    $_SERVER['HTTP_REFERER']."\">".
                    $_SERVER['HTTP_REFERER']."</a> ".
                    $_SERVER['HTTP_USER_AGENT']);
                fwrite($db,"<br> RemoteAddr: <a href=\"http://www.melissadata.com/lookups/iplocation.asp?ipaddress=".
                    $_SERVER['REMOTE_ADDR']."\">".
                    $_SERVER['REMOTE_ADDR']."</a> 
                    RemoteHost:".$_SERVER['REMOTE_HOST']." ");
#		echo $thedate." ".$_SERVER['HTTP_REFERER']." ".$_SERVER[HTTP_USER_AGENT]." ".$_SERVER[REMOTE_ADDR]." ".$_SERVER[REMOTE_HOST]."\n";
		fwrite($db,$IP." ".$get_host." ".$country_code."\n");
                fclose($db);
}
		?>

