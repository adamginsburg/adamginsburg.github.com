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
                if (ereg("Slurp",$_SERVER['HTTP_USER_AGENT']) ||
                    ereg("Googlebot",$_SERVER['HTTP_USER_AGENT']) || 
                    ereg("ia_archiver",$_SERVER['HTTP_USER_AGENT']) || 
                    ereg("Exabot",$_SERVER['HTTP_USER_AGENT']) || 
                    ereg("msnbot",$_SERVER['HTTP_USER_AGENT'])) { 
                        fwrite($db,"<br>BOT");
                        fclose($db);
                    }
                else{ 
                    fwrite($db,"<br><b>".$page."</b>: ".$thedate." <a href=\"".
                        $_SERVER['HTTP_REFERER']."\">".
                        $_SERVER['HTTP_REFERER']."</a> ".
                        $_SERVER['HTTP_USER_AGENT']);
                    fwrite($db,"<br> RemoteAddr: <a href=\"http://ws.arin.net/whois/?queryinput=".
                        $_SERVER['REMOTE_ADDR']."\">".
                        $_SERVER['REMOTE_ADDR']."</a> 
                        RemoteHost:".$_SERVER['REMOTE_HOST']." ");
    #		echo $thedate." ".$_SERVER['HTTP_REFERER']." ".$_SERVER[HTTP_USER_AGENT]." ".$_SERVER[REMOTE_ADDR]." ".$_SERVER[REMOTE_HOST]."\n";
                    fwrite($db,$IP." ".$get_host." ".$country_code."\n");
                    fclose($db);
                }
}
		?>

