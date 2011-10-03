<html>
<head>
<title> LMC Post-AGB Database </title>
</head>
<body>
<?php echo "<p>Table of post-AGBs from SAGE survey of LMC</p><br><br>Warning: 
the arrows in the MCPS fits are of questionable accuracy, and in some cases 
(i.e. those where the source was near the edge of an MCPS frame) they are 
definitely wrong.  The same applies for 2MASS cutouts; they were extracted from the
IRSA 2mass image archive and therefore in many cases are cut off.  Also note that
the images are NOT on the same scale.<br>
<a href=plots.php> Color-color and Color-magnitude diagrams</a><br>"; 
$handle = fopen("plotme.csv","r");
echo "<table>";
$header =  fgetcsv ( $handle , 5000 , "," ) ;
echo "<tr><td>All Images</td><td>MCPS image</td><td>2mass J</td><td>2mass H</td><td>2mass K</td><td>IRAC 3.6um</td><td>4.5um</td><td>5.8um</td><td>8.0um</td><td>24um</td><td>70um</td><td>160um</td><td>SED </td><td>SIMBAD</td><td>IRSA/Vizier</td><td>MACHO</td>" ;
for ($i=0; $i<count($header); $i++) {
		if ($header[$i] == "IracDesignation" || $header[$i] == "RA" || $header[$i] == "Dec" 
				|| $header[$i] == "type" || $header[$i] == "notes" || $header[$i] == "locationnotes") {
						echo "<td>{$header[$i]}</td>";
						}
		$headindex[$header[$i]] = $i;
}
$linenum = 0;
while(($db = fgetcsv ( $handle , 5000 , "," )) !== FALSE ) {
		$numfields = count($db) ;
		echo "<tr>";
		$iracdes = $db[6];
		$pattern = '/[\s ]/';
		$replacement = '_';
		$iracdes = preg_replace($pattern,$replacement,$iracdes);
		$twom = substr($iracdes,11,15);
		$fts = $db[130];
		echo "<td><a href=\"individual.php?filename=$iracdes&fts=$fts\"> $iracdes </a></td>";
		echo "<td><a href=\"".$iracdes."_mcps.fits\">  MCPS I-band fits </a>";
		echo "<a href=\"".$iracdes."_mcps.gif\"> gif </a></td>";
		echo "<td><a href=\"$twom"."_aJ.fits\"> 2MASS J-band fits </a>";
		echo "<a href=\"$twom"."_aJ.gif\">  gif </a></td>";
		echo "<td><a href=\"$twom"."_aH.fits\"> 2MASS H-band fits </a>";
		echo "<a href=\"$twom"."_aH.gif\">  gif </a></td>";
		echo "<td><a href=\"$twom"."_aK.fits\"> 2MASS K-band fits </a>";
		echo "<a href=\"$twom"."_aK.gif\">  gif </a></td>";
		echo "<td><a href=\"".$iracdes."_glm_mosaic_ch1_sage1_2s.fits\"> 3.6um fits </a>";
		echo "<a href=\"".$iracdes."_glm_mosaic_ch1_sage1_2s.gif\"> gif </a></td>";
		echo "<td><a href=\"".$iracdes."_glm_mosaic_ch2_sage1_2s.fits\"> 4.5um fits </a>";
		echo "<a href=\"".$iracdes."_glm_mosaic_ch2_sage1_2s.gif\"> gif </a></td>";
		echo "<td><a href=\"".$iracdes."_glm_mosaic_ch3_sage1_2s.fits\"> 5.8um fits </a>";
		echo "<a href=\"".$iracdes."_glm_mosaic_ch3_sage1_2s.gif\"> gif </a></td>";
		echo "<td><a href=\"".$iracdes."_glm_mosaic_ch4_sage1_2s.fits\"> 8.0um fits </a>";
		echo "<a href=\"".$iracdes."_glm_mosaic_ch4_sage1_2s.gif\"> gif </a></td>";
		echo "<td><a href=\"".$iracdes."_sage_mips70_mipsenh_21jun06.cal.fits\"> 70um fits </a>";
		echo "<a href=\"".$iracdes."_sage_mips70_mipsenh_21jun06.cal.gif\"> gif </a></td>";
		echo "<td><a href=\"".$iracdes."_sage_mips160_mipsenh_21jun06.cal.fill_gap.modsub.fits\"> 160um fits </a>";
		echo "<a href=\"".$iracdes."_sage_mips160_mipsenh_21jun06.cal.fill_gap.modsub.gif\"> gif </a></td>";
		echo "<td><a href=\"".$iracdes."_sage_mips24_montage32_rot_22jun06.cal.fits\"> 24um fits </a>";
		echo "<a href=\"".$iracdes."_sage_mips24_montage32_rot_22jun06.cal.gif\"> gif </a></td>";
		echo "<td><a href=\"".$iracdes.".png\"> png </a>";
		echo "<a href=\"".$iracdes.".cps\"> cps </a>";
		echo "<a href=\"".$iracdes.".txt\"> txt </a></td>";
		echo "<td><a href=\"http://simbad.u-strasbg.fr/simbad/sim-coo?CooEpoch=2000&Coord=".$db[16]." ".$db[17]."&submit=submit query&Radius.unit=arcsec&CooEqui=2000&CooFrame=FK5&Radius=3\"> SIMBAD: ".$db[$headindex['other_id']]."</a>";
		echo "<a href=\"http://nedwww.ipac.caltech.edu/cgi-bin/nph-objsearch?in_csys=Equatorial&in_equinox=J2000.0&lon=".$db[16]."d&lat=+".$db[17]."d&radius=.05&search_type=Near+Position+Search\">  NED  </a></td>";
		echo "<td><a href=\"http://irsa.ipac.caltech.edu/cgi-bin/Radar/nph-estimation?objstr=".$db[16]."+".$db[17]."&submit=Get+Inventory&mode=cone&radius=3&radunits=arcsec&mission=All&irsa=IRSA+and+Vizier\"> IRSA/Vizier Query (3\") </a>";
		echo "<a href=\"http://heasarc.gsfc.nasa.gov/db-perl/W3Browse/w3query.pl?tablehead=name%253D%2540All%255FArchives%2526&Coordinates=Equatorial%3A+R.A.+Dec&Entry=".$db[16].",".$db[17]."&maxrows=100&Equinox=2000&Radius=0.05&Radius_unit=arcmin&requery=Reissue+Query&displaymode=Display\"> HEASARC </a>";
		echo "<a href=\"http://archive.stsci.edu/cgi-bin/genlinks_search.cgi?target=".$db[16].",".$db[17]."&radius_acs=.1&radius_wfpc2=.1&radius_iue=.1&radius_foc=.1&radius_wfpc1=.1&radius_nicmos=.1&radius_stis=.1\">  MAST (3')  </a></td>";
		if ($db[130] == "null") {
				echo "<td> no MACHO </td>";
		} else {
				echo "<td><a href=\"http://store.anu.edu.au:3001/cgi-bin/fts.pl?F.T.S=".$fts."&Action=Submit\"> MACHO lightcurve </a>";
				echo "<a href=\"".$fts.".txt\"> txt </a>";
				echo "<a href=\"macho.php?fts=$fts\"> Plot </a></td>";
		}
		for ($i=0; $i<$numfields; $i++) {
				if ($header[$i] == "IracDesignation" || $header[$i] == "RA" || $header[$i] == "Dec" 
						|| $header[$i] == "type" || $header[$i] == "notes" || $header[$i] == "locationnotes") {
								echo "<td>".$db[$i]."</td>";
						}
		}
		echo "</tr>\n";
		$linenum++;
}

?>
</body>
</html>
