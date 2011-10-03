<?php
header("Content-type: image/png");
/*$handle=@ImageCreate(130,50) or die("can't make img");
$bgcolor=imagecolorallocate($handle,255,0,0);
$txtcolor=imagecolorallocate($handle,255,255,255);
for ($i=0;$i<129;$i=$i+5) {
		imageline($handle,65,0,$i,50,$txtcolor);
}
$imagestring($handle,5,5,18,"moo",$txtcolor);
imagepng($handle);*/

$xsize=800;
$ysize=600;
$offset=75;
$yoffset=30;
$im = @imagecreate($xsize+$offset,$ysize+$yoffset) or die("Can't make a new image\n");
$backgroundcolor = imagecolorallocate($im,255,255,255);
$black = imagecolorallocate($im,0,0,0);
$blue = imagecolorallocate($im,0,0,255);
$red = imagecolorallocate($im,255,0,0);

$filename = $_REQUEST['fts'].".txt";
#echo "file $filename";
#imagestring($im,5,200,50,"file $filename",$black);
$fh = fopen($filename,'r');

$i=0;
while ($line = fgets($fh)) {
		if (substr($line,0,1) == "#" || substr($line,0,1) == "!" 
				|| substr($line,80,7) == -99 || substr($line,160,7) == -99
				|| substr($line,89,5) < 0 || substr($line,169,5) < 0
				|| substr($line,89,5) == 9.999 || substr($line,169,5) == 9.999
				|| substr($line,80,7) == "" || substr($line,80,7) == 0
				|| substr($line,160,7) == "" || substr($line,160,7) == 0) {continue;}
		$red_array[$i] = substr($line,80,7);
		$blue_array[$i] = substr($line,160,7);
		$red_err[$i] =  substr($line,89,5);
		$blue_err[$i] = substr($line,169,5);
		$i++;
}
$max_r = $red_array;
rsort($max_r);
$max_b = $blue_array;
rsort($max_b);
if ($max_r[0] > $max_b[0]) {$max = $max_r[0];}
else {$max=$max_b[0];}
$last=count($red_array)-1;
if ($max_r[$last] < $max_b[$last]) {$min = $max_r[$last];}
else {$min=$max_b[$last];}
$scaley = $ysize/($max-$min);
$scalex = $xsize/count($red_array);
#imagestring($im,5,0,0,"Yscale: $scaley max: $max min: $min",$red);
#imagestring($im,5,0,100,"Xscale: $scalex min_b:".$max_b[$last],$red);
#imagestring($im,5,0,200,"count: ".count($red_array)." min_r:".$max_r[$last],$red);


imageline($offset,0,0,$ysize,$black);
imageline($offset,0,$xsize,0,$black);
imageline($offset,$ysize,$xsize,$ysize,$black);
imageline($offset+$xsize,0,$xsize,$ysize,$black);
imagestring($im,5,0,0,$min,$black);
$mid = ($min+$max)/2;
imagestring($im,5,0,$ysize/2,$mid,$black);
imagestring($im,5,0,$ysize,$max,$black);


for ($i=0;$i<count($red_array);$i++) {
		$x=$scalex*$i+$offset;
		$yredlow = ( $red_array[$i] - $red_err[$i] -$min ) * $scaley;
		$yredhigh = ( $red_array[$i] + $red_err[$i]  -$min) * $scaley;
		$ybluelow = ( $blue_array[$i] - $blue_err[$i]  -$min) * $scaley;
		$ybluehigh = ( $blue_array[$i] + $blue_err[$i]  -$min) * $scaley;
#		if ($yredlow > $ysize) {$yredlow=$ysize-1;}
#		if ($ybluelow > $ysize) {$ybluelow=$ysize-1;}
#		if ($ybluehigh > $ysize) {$ybluehigh=$ysize-1;}
#		if ($yredhigh > $ysize) {$yredhigh=$ysize-1;}
#		if ($yredlow < 0) {$yredlow=0;}
#		if ($ybluelow < 0) {$ybluelow=0;}
#		if ($ybluehigh < 0) {$ybluehigh=0;}
#		if ($yredhigh < 0) {$yredhigh=0;}
#		if ($i==5) {
#				imagestring($im,5,0,150,"x: $x yred: $yredlow - $yredhigh yblue: $ybluelow - $ybluehigh",$blue);
#				imagestring($im,5,0,175,"i: $i min: $min max: $max last: $last",$blue);
#		}
		imageline($im,$x,$yredlow,$x,$yredhigh,$red);
		imageline($im,$x,$ybluelow,$x,$ybluehigh,$blue);
}

imagepng($im);
imagedestroy($im);
?>

