#!/usr/bin/perl 
use CGI qw(:standard);
use strict;
#use warnings; #these don't behave very well

#Open files.  database.dat contains shock models,
#measurements.dat contails default measurement data,
#output.txt MUST HAVE WRITE PERMISSIONS! 
open(model,"<database.dat") or die "Can't open database.dat\n";
open(measure,"<measurements.dat") or die "Can't open measurements.dat\n";
open(outfile,">output.txt") or die "Can't write to output.txt.\n";

#variable declarations
my(@temp,@measarray,@linenames,@linenum,@ratiodb,@measured_ratio,@sigma,@model_arr,@dbmeas);
my($userin,$rcin);
my($aref,$i,$j,$top,$bottom,$sig1,$sig2,$chi2,$chired,$model_ratio,$x,$y,$han,$haflux,$redcor,$text);

#This gigantic array contains all of the ratios to be calculated.  Left is top, right is bottom.
@ratiodb = ( 
	#Fe7390 block
	["Fe7390","Fe5160"],["Fe7390","N5200"],["Fe7390","C9850"],["Fe7390","O6300"],["Fe7390","HA6563"],
	["Fe7390","N6583"],["Fe7390","S6716"],["Fe7390","S6731"],["Fe7390","Fe7155"],["Fe7390","Fe7172"],
	["Fe7390","Ca7291"],["Fe7390","Fe7452"],["Fe7390","Fe8619"],["Fe7390","HB4861"],["Fe7390","Fe5262"],
	["Fe7390","O5577"],["Fe7390","N5755"],["Fe7390","C8730"],
	#["Fe7390","O7330"],["Fe7390","O5007"],
	#C8730 block
	["C8730","Fe5160"],["C8730","N5200"],["C8730","C9850"],["C8730","O6300"],["C8730","HA6563"],
	["C8730","N6583"],["C8730","S6716"],["C8730","S6731"],["C8730","Fe7155"],["C8730","Fe7172"],
	["C8730","Ca7291"],["C8730","Fe7452"],["C8730","Fe8619"],["C8730","HB4861"],["C8730","Fe5262"],
	["C8730","O5577"],["C8730","N5755"],
	#["C8730","O7330"],["C8730","O5007"],
	#N5755 block
	["N5755","Fe5160"],["N5755","N5200"],["N5755","C9850"],["N5755","O6300"],["N5755","HA6563"],
	["N5755","N6583"],["N5755","S6716"],["N5755","S6731"],["N5755","Fe7155"],["N5755","Fe7172"],
	["N5755","Ca7291"],["N5755","Fe7452"],["N5755","Fe8619"],["N5755","HB4861"],["N5755","Fe5262"],
	["N5755","O5577"],
	#["N5755","O7330"],["N5755","O5007"],
	#O5577 block
	["O5577","Fe5160"],["O5577","N5200"],["O5577","C9850"],["O5577","O6300"],["O5577","HA6563"],
	["O5577","N6583"],["O5577","S6716"],["O5577","S6731"],["O5577","Fe7155"],["O5577","Fe7172"],
	["O5577","Ca7291"],["O5577","Fe7452"],["O5577","Fe8619"],["O5577","HB4861"],["O5577","Fe5262"],
	#["O5577","O7330"],["O5577","O5007"]
	#Fe5262 block
	["Fe5262","Fe5160"],["Fe5262","N5200"],["Fe5262","C9850"],["Fe5262","O6300"],["Fe5262","HA6563"],
	["Fe5262","N6583"],["Fe5262","S6716"],["Fe5262","S6731"],["Fe5262","Fe7155"],["Fe5262","Fe7172"],
	["Fe5262","Ca7291"],["Fe5262","Fe7452"],["Fe5262","Fe8619"],["Fe5262","HB4861"],#["Fe5262","O7330"],
#	["Fe5262","O5007"],
#	#O5007 block.  O5007  is not in the database yet (don't know how to use upper limits)
#	["O5007","Fe5160"],["O5007","N5200"],["O5007","C9850"],["O5007","O6300"],["O5007","HA6563"],
#	["O5007","N6583"],["O5007","S6716"],["O5007","S6731"],["O5007","Fe7155"],["O5007","Fe7172"],
#	["O5007","Ca7291"],["O5007","Fe7452"],["O5007","Fe8619"],["O5007","O7330"],["O5007","HB4861"],
	#HB4861 block
	["HB4861","Fe5160"],["HB4861","N5200"],["HB4861","C9850"],["HB4861","O6300"],["HB4861","HA6563"],
	["HB4861","N6583"],["HB4861","S6716"],["HB4861","S6731"],["HB4861","Fe7155"],["HB4861","Fe7172"],
	["HB4861","Ca7291"],["HB4861","Fe7452"],["HB4861","Fe8619"],#["HB4861","O7330"],
#	#O7330 block O7330 is a blend of O and Ca, so I don't know what to do with it
#	["O7330","Fe5160"],["O7330","N5200"],["O7330","C9850"],["O7330","O6300"],["O7330","HA6563"],
#	["O7330","N6583"],["O7330","S6716"],["O7330","S6731"],["O7330","Fe7155"],["O7330","Fe7172"],
#	["O7330","Ca7291"],["O7330","Fe7452"],["O7330","Fe8619"],
	#Fe8619 block
	["Fe8619","Fe5160"],["Fe8619","N5200"],["Fe8619","C9850"],["Fe8619","O6300"],["Fe8619","HA6563"],
	["Fe8619","N6583"],["Fe8619","S6716"],["Fe8619","S6731"],["Fe8619","Fe7155"],["Fe8619","Fe7172"],
	["Fe8619","Ca7291"],["Fe8619","Fe7452"],
	#C9850 block
	["C9850","N5200"],["C9850","O6300"],["C9850","HA6563"],["C9850","N6583"],["C9850","S6716"],["C9850","S6731"],
	["C9850","Fe5160"],["C9850","Fe7155"],["C9850","Fe7172"],["C9850","Ca7291"],["C9850","Fe7452"],
	#Fe7452 block
	["Fe7452","Ca7291"],["Fe7452","Fe7172"],["Fe7452","Fe7155"],["Fe7452","S6716"],["Fe7452","S6731"],["Fe7452","N6583"],
	["Fe7452","HA6563"],["Fe7452","O6300"],["Fe7452","N5200"],["Fe7452","Fe5160"],
	#Ca7291 block
	["Ca7291","Fe7172"],["Ca7291","Fe7155"],["Ca7291","S6731"],["Ca7291","S6716"],["Ca7291","N6583"],
	["Ca7291","Ha6563"],["Ca7291","O6300"],["Ca7291","N5200"],["Ca7291","Fe5160"],
	#Fe7172 block
	["Fe7172","Fe7155"],["Fe7172","S6731"],["Fe7172","S6716"],["Fe7172","N6583"],
	["Fe7172","Ha6563"],["Fe7172","O6300"],["Fe7172","N5200"],["Fe7172","Fe5160"],
	#Fe7155
	["Fe7155","S6731"],["Fe7155","S6716"],["Fe7155","N6583"],
	["Fe7155","Ha6563"],["Fe7155","O6300"],["Fe7155","N5200"],["Fe7155","Fe5160"],
	#S6731 block
	["S6731","S6716"],["S6731","N6583"],["S6731","Ha6563"],["S6731","O6300"],["S6731","N5200"],["S6731","Fe5160"],
	#S6716 block
	["S6716","N6583"],["S6716","Ha6563"],["S6716","O6300"],["S6716","N5200"],["S6716","Fe5160"],
	#N6583 block
	["N6583","Ha6563"],["N6583","O6300"],["N6583","N5200"],["N6583","Fe5160"],
	#HA6563 block
	["HA6563","O6300"],["HA6563","N5200"],["HA6563","Fe5160"],
	#O6300
	["O6300","N5200"],["O6300","Fe5160"],
	#N5200
	["N5200","Fe5160"]
);

#Various printed things, like header, start_html,br,p,td(), etc. are CGI.pm commands to make html
print header,start_html("Shock Model Fits");
print "Please enter lines you wish to compare in the format seen below. (the default is HH34 knot F) <br>
	You can also enter a reddening correction C (logarithmic extinction of HBeta) if you choose to.",br,
	#"You must include all of the lines listed under default with the names listed or the script will fail.<br>
	"You can use lower limits by giving a non-zero error and zero for the measurement<br>
	<p> Input information: <br>
	O6300 is a combination of [O I] 6300 and [O I] 6363<br>
	C9850 is a combination of [C I] 9850 and [C I] 9823<br>
	N5200 is a combination of [N I] 5198 and [N I] 5201<br>
	N6583 is a combination of [N II] 6583 and [N II] 6548<br>
	Name - Measured Strength relative to Halpha - 1 sigma error",br;

#populates the default data input
while (<measure>) { 
	@temp = split;
	$text="$text$temp[0]\t" . sprintf("%.2f\t",$temp[1]) . sprintf("%.3f\n",$temp[2]);
}
close (measure);

#User input
print start_form, 
	textarea(-name=>'boxin', -default=>$text, -rows=>15, -columns=>50),
	#submit(-name=>'meas',-value=>'Submit Data'),
	defaults,br,p,
	"Reddening Correction:",
	textfield(-name=>'redcor', -default=>'0'),br,
	radio_group(-name=>'rctype',-values=>['C','E(B-V)','A(V)'],-default=>'C',-linebreak=>'false'),
	submit(-name=>'rc',-value=>'Submit'),br,
	end_form,hr;
$redcor = param('redcor');
$rcin = param('rctype');
$userin = param('boxin');
@temp = split (/\n/,$userin);
for $aref (@temp) {
	push @measarray, [ split (/\s+/, $aref) ]; #populate user input data array
}

#Dealing with upper limits
#If an upper limit is used, it is treated as though the measured value is half of the 
#measured error, and the measured error is cut in half
$x=$#measarray;  $i=0;
for $y (0 .. $#measarray) {
	if ($i > $x) {last;} #Error check necessary because I'm removing elements
	if ($measarray[$i][1]==0 && $measarray[$i][2]!=0) {
		$measarray[$i][1]=$measarray[$i][2]/2;
		$measarray[$i][2]=$measarray[$i][1];
		$i++;
	}
	elsif ($measarray[$i][1]==0 && $measarray[$i][2]==0 || $measarray[$i][1] < 0) {
		splice (@measarray,$i,1); #removes any lines with 0 0 or a value <0
		$x--;
	}
	else {$i++;} #these extra incrementers are used because the perl loop will keep incrementing until it reaches
		#the static value of whatever $#measarray was at the beginning, but I want it to cut off at a lower value
		#without skipping any of the indices
}

#Reddening Correction
if ($redcor != 0) {
	my($a,$b,$L,$Av,$Rv,@corr,$C,$HA,@errcorr);	
	$Rv=3.1;
	#Manual switch statement because perl 5.8 isn't good at switching on its own
		if ($rcin eq "C")	 	{ $C=$redcor;	$Av = 3.1 * $C * (.61 + .24 * $C);} #logarithmic extinction of HB
			#c=3 (log (F(HA)/F(HB)) - 3).  It should be simple to add an automatic reddening correction section
		elsif ($rcin eq "E(B-V)")	{ $Av=$Rv*$redcor; } #Blue-Violet color excess
		elsif ($rcin eq "A(V)")		{ $Av=$redcor; } #Absolute 
		else				{ print "Error: Radio button failure."; }
	for $x ( 0 .. $#measarray ) {
		$measarray[$x][0] =~ m/(\d+)/;
		$L=1e-4*$1;
		$y=1/$L-1.82;
		$a=1+0.17699*$y-0.50447*($y**2)-0.02427*($y**3)+0.72085*($y**2)+0.01979*($y**5)-0.7753*($y**6)+0.32999*($y**7);
		$b=1.41338*$y+2.28305*($y**2)+1.07233*($y**3)-5.38434*($y**4)-0.62251*($y**5)+5.3026*($y**6)-2.09002*($y**7);
		$corr[$x]=$measarray[$x][1]*(10**(.4*$Av*($a+$b/$Rv))); 
		if ($measarray[$x][0] eq "HA6563") { $HA = $corr[$x];}
	}
	#This loop is needed because $HA must be set before you reset the values of @measarray
	for $x ( 0 .. $#measarray ) {
		if ($HA !=0) {
			if ($measarray[$x][1]!=0) {$errcorr[$x]=($measarray[$x][2]/$measarray[$x][1])*$corr[$x]/$HA;}
			else {$errcorr[$x]=$measarray[$x][2];}
		} else {die "Halpha is zero!";}
		$measarray[$x][3]=$measarray[$x][1];#save the old (un-reddening corrected) values for output later
		$measarray[$x][4]=$measarray[$x][2];
		$measarray[$x][1]=$corr[$x]/$HA;
		$measarray[$x][2]=$errcorr[$x];
	}
	print "Reddening correction used: $rcin = $redcor\n",br,p;
}


#Find measured ratios by matching ratiodb to the first column of measarray
my ($top2, $bottom2, $sig3, $sig4, @mrold, @sigold, $flag);
$x=$#ratiodb; $y=0;
for $i (0 .. $#ratiodb ) {
	if ($y > $x) { last; } #because I'm removing elements at the end, I need an error check to quit the loop early
	$top=0, $bottom=0, $sig1=0, $sig2=0;
	$top2=0, $bottom2=0, $sig3=0, $sig4=0, $flag=0;
	$i=$y;
	$measured_ratio[$i]=0; $sigma[$i]=0;
	for $j (0 .. $#measarray) {
		if ($measarray[$j][0] eq $ratiodb[$i][0]) {
			$top=$measarray[$j][1];
			$sig1=$measarray[$j][2];
			if ($redcor != 0) {#all the redcor!=0 statements are to keep the original measured ratios around
				$top2=$measarray[$j][3];
				$sig3=$measarray[$j][4];
			}
		}
		elsif ($measarray[$j][0] eq $ratiodb[$i][1]) {
			$bottom=$measarray[$j][1];
			$sig2=$measarray[$j][2];
			if ($redcor != 0) {
				$bottom2=$measarray[$j][3];
				$sig4=$measarray[$j][4];
			}
		}
		if ($top!=0 && $bottom!=0) {
			$measured_ratio[$i]=$top/$bottom;
			$sigma[$i]=sqrt(($sig1/$top)**2+($sig2/$bottom)**2)*$top/$bottom;
			if ($redcor != 0) {
				$mrold[$i]=$top2/$bottom2;
				$sigold[$i]=sqrt(($sig3/$top2)**2+($sig4/$bottom2)**2)*$top2/$bottom2;
			}
		}
	}
	#What if we don't have either or both of the elements in the ratio?
	#If we're at the last element of measarray without finding a match, kill that ratio
	if ($measured_ratio[$i]==0) {
		splice (@ratiodb,$i,1); #remove this row from the ratio database
		splice (@measured_ratio,$i,1);
		splice (@sigma,$i,1);
		$x--; 
	}
	else {$y++;}
}
	

#Creates index for later use
@linenames=split(/\s/,<model>);
$j=0;
for $aref (@ratiodb) {
	for $i ( 0 .. $#linenames ) {
		if ($linenames[$i] eq @$aref[0]) 	{$linenum[$j][0]=$i;	}
		if ($linenames[$i] eq @$aref[1]) 	{$linenum[$j][1]=$i;	}
		if ($linenames[$i] eq "HA6563") 	{$han=$i;		}
	}
	$j+=1;
}

#begin creating the "best fit models" table
print "<table frame=box rules=all cellspacing=6 cellpadding=15>", 
	caption(h1("Top 6 Shock Model Fits")),"<tr>",th("Red. Chi2");
for $i (0 .. 11) { 
	print th($linenames[$i]); 
}
print "</tr>";

#Calculate the reduced chi squared for each shock model
while (<model>) {
	@temp = split;
	$haflux=$temp[$han];
	$temp[$han]=1; #All hydrogen alpha should be 1
	$chi2=0; $i=0;
	for $j ( 0 .. $#ratiodb ) {
		$x=$linenum[$j][0];
		$y=$linenum[$j][1];
		if ($temp[$x] > 0 && $temp[$y] > 0)	{ 
			$model_ratio=$temp[$x]/$temp[$y];
			$chi2+=(($measured_ratio[$j]-$model_ratio)/$sigma[$j])**2; #chisquared for a given model is the sum of the individual chisquareds
		}
		else { $i+=1;} #if we get zeros in the models, don't count them in N		
	}
	if ($j == $i)	{
		$chired=0;
		print "Warning: a model has all zero values.  The database may be corrupted.";
	}
	else {	$chired=$chi2/($j-$i);  } #reduced chi-squared 
	unshift @temp, $chired ; #plugs chired on the front of temp
	push @model_arr, [ @temp  ] ; #rebuild model array
}

#sort by lowest chisquared.  Notice we're comparing the first element [0] of each element $a or $b
@temp = sort { $a->[0] <=> $b->[0] } @model_arr ;  
@model_arr=@temp;

#Table containing 6 best fit models and their info
for  $i (0 .. 5) {
	print "<tr>";
       	for $j (0 .. 12) {
		print td(sprintf("%.4g",$model_arr[$i][$j]));
	}
	print "</tr>";
}
print "</table>";

#Table containing each line ratio measured for the 6 best fit models
$j=0;
print br,p,"<table frame=box rules=all cellspacing=6 cellpadding=6>",
	caption(b(h1("Best shock model line ratios"))),	"<tr>", 
	th("Line"),th("Obs"),th("Obs Err"),th("RC"),th("RC err");
	for $i (0 .. 5) { print th("Model $i"),th("ChiSq $i"); }
print "</tr>";
for $aref (@ratiodb) {
	print "<tr>",td("@$aref[0]/@$aref[1]");
	if ($redcor != 0) {
		print td(sprintf("%.2f",$mrold[$j])),td(sprintf("%.2f",$sigold[$j]));
		print td(sprintf("%.2f",$measured_ratio[$j])),td(sprintf("%.2f",$sigma[$j]));
	}
	else {
		print td(sprintf("%.2f",$measured_ratio[$j])),td(sprintf("%.2f",$sigma[$j]));
		print td(),td();
	}
	for $i (0 .. 5) {
		if ($model_arr[$i][1+$linenum[$j][1]] > 0) {
			if ($linenum[$j][1]==$han) { $model_ratio = $model_arr[$i][1+$linenum[$j][0]];}
			elsif ($linenum[$j][0]==$han) { $model_ratio = 1/$model_arr[$i][1+$linenum[$j][1]];}
			else  {	$model_ratio=$model_arr[$i][1+$linenum[$j][0]]/$model_arr[$i][1+$linenum[$j][1]]; }
			print td(sprintf("%.2f",$model_ratio)),
			td(sprintf("%.2f",(($measured_ratio[$j]-$model_ratio)/$sigma[$j])**2));
		}
		else {print td(),td();}
	}
	print "</tr>";
	$j+=1;
}
print "</table>";

#Output all of the data to output.txt
print outfile "ChiSq\t" . join("\t",@linenames) . "\n";
for $aref (@model_arr) {
	@temp=@$aref;
	for $i (0 .. $#temp) {
		print outfile sprintf("%.4g\t",@$aref[$i]);
	}
	print outfile "\n";
}
print br,"<a href=\"output.txt\">Output File</a>  I recommend pasting this into an excel (or openoffice calc) 
	file for readability.  It is tab-separated, but the tabs don't always line up perfectly.",br,br;

print p,"References:<br>
(for conversion between C and A_V) <a href=\"http://adsabs.harvard.edu/cgi-bin/nph-bib_query?bibcode=1985PASP...97..700K&amp;db_key=AST&amp;data_type=HTML&amp;format=&amp;high=42e8fc0ad504980\"> Kaler and Lutz, <b>PASP 97:700</b>, 1985</a>,<a href=\"http://arxiv.org/PS_cache/astro-ph/pdf/0403/0403531.pdf\"> Another derived from Osterbrock's 1989 book on nebulae</a><br>
(for reddening law) <a href=\"http://adsabs.harvard.edu/cgi-bin/nph-bib_query?bibcode=1989ApJ...345..245C&amp;db_key=AST&amp;data_type=HTML&amp;format=&amp;high=42e8fc0ad507810\"> Cardelli, Clayton, and Mathis, <b>ApJ 345:245</b>, 1989</a><br>
(for E(B-V) to E(beta-alpha) comparison) <a href=\"http://adsabs.harvard.edu/cgi-bin/nph-bib_query?bibcode=1968ApJ...153..743G&amp;db_key=AST&amp;data_type=HTML&amp;format=&amp;high=42e8fc0ad510407\"> Gebel, <b>ApJ 153:743</b> 1968 (eqn 2)</a><br><br>
Contact: <a href=\"mailto:keflavich\@gmail.com\">Adam Ginsburg</a> or 
<a href=\"mailto:hartigan\@sparky.rice.edu\">Pat Hartigan</a> for more information",br,
"Last updated by Adam Ginsburg now 5/12/06";


close(model);
close(outfile);
print end_html;
