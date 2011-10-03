<html>
<head>
<title> LMC Post-AGB Database - Color-Color and Color-Magnitude diagrams </title>
</head>
<body>
<?php
exec('ls *onlypagbs*png',$list,$ret);
echo "Color-color and Color-magnitude diagrams<br>";
echo "<a href=\"legend.png\"> <img src=\"legend.png\" title=Legend width=300> </a>\n";
if ($ret == 0) {
#		print "<br>LS worked OK.<br>\n";
		foreach ($list as $line) {
				$name = $line;
				$pattern = '/onlypagbs.*/';
				$replacement = '';
				$name = preg_replace($pattern,$replacement,$name);
				echo "<a href=\"$line\"> <img src=\"$line\" title=$name width=300> </a>\n";
#				echo "Hi.";
#				echo "<br> line: $line, name: $name  \n";
		}
} else {
		echo "Error in ls command.";
}
?>
</body>
</html>
