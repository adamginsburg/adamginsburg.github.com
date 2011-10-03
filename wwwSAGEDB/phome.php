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
the images are NOT on the same scale.  The gif images provided are intended to surve as 
simple quick-look finding charts; any serious comparison between the images should make 
use of the fits versions provided. <br>
<a href=plots.php> Color-color and Color-magnitude diagrams</a><br>"; 
echo "<br> Units:
		<br> Flux: W m^-2 = 10^-3 erg cm^-2 s^-1 
		<br> Luminosity: Lsol
		<br> Temperature: K
		<br>";
$handle = fopen("plotme.csv","r");
$header =  fgetcsv ( $handle , 5000 , "," ) ;
echo "<table border=\"1\" rules=\"rows\">";
echo "<tr><td>All Images</td>";
#<td>MCPS image</td><td>2mass J</td><td>2mass H</td><td>2mass K</td>
#		<td>IRAC 3.6um</td><td>4.5um</td><td>5.8um</td><td>8.0um</td><td>24um</td><td>70um</td><td>160um</td>
#echo "		<td>SED </td><td>SIMBAD</td><td>IRSA/Vizier</td><td>MACHO</td>" ;
echo "<td>Catalog Searches</td><td>MACHO</td>";
for ($i=0; $i<count($header); $i++) {
		if ($header[$i] == "racDesignation" 
				|| $header[$i] == "type" || $header[$i] == "notes" ) {
						echo "<td>{$header[$i]}</td>";
				} elseif ($header[$i] == "RA") {
						echo "<td>Location</td>";
				}

		$headindex[$header[$i]] = $i;
}
echo "<td>Model Information</td>
		<td>Integrated Flux</td>\n";
$linenum = 0;
while(($db = fgetcsv ( $handle , 5000 , "," )) !== FALSE ) {
		$numfields = count($db) ;
		echo "<tr>";
		$iracdes = $db[6];
		$pattern = '/[\s ]/';
		$replacement = '_';
		$iracdes = preg_replace($pattern,$replacement,$iracdes);
		$twom = "SSTISAGE1C_" . substr($iracdes,11,15);
		$fts = $db[131];
		echo "<td><table><tr>";
		echo "<td><a href=\"individual.php?filename=$iracdes&fts=$fts\"> $iracdes </a>";
		echo "<tr><td>MCPS I-band: <td><a href=\"".$iracdes."_mcps.fits\"> fits </a>";
		echo "<td><a href=\"".$iracdes."_mcps.gif\"> gif </a></tr>";
		echo "<tr><td>2MASS J-band:<td><a href=\"$twom"."_2MASS_J.fits\"> fits </a></td>";
		echo "<td><a href=\"$twom"."_2MASS_J.gif\">  gif </a></td></tr>";
		echo "<tr><td>2MASS H-band:<td> <a href=\"$twom"."_2MASS_H.fits\"> fits </a></td>";
		echo "<td><a href=\"$twom"."_2MASS_H.gif\">  gif </a></tr>";
		echo "<tr><td>2MASS K-band:<td> <a href=\"$twom"."_2MASS_K.fits\"> fits </a></td>";
		echo "<td><a href=\"$twom"."_2MASS_K.gif\">  gif </a></tr>";
		echo "<tr><td> 3.6um: <td><a href=\"".$iracdes."_irac_ch1.fits\"> fits </a>";
		echo "<td><a href=\"".$iracdes."_irac_ch1.gif\"> gif </a></tr>";
		echo "<tr><td>4.5um: <td><a href=\"".$iracdes."_irac_ch2.fits\"> fits </a>";
		echo "<td><a href=\"".$iracdes."_irac_ch2.gif\"> gif </a></tr>";
		echo "<tr><td>5.8um: <td><a href=\"".$iracdes."_irac_ch3.fits\"> fits </a>";
		echo "<td><a href=\"".$iracdes."_irac_ch3.gif\"> gif </a></tr>";
		echo "<tr><td>8.0um: <td><a href=\"".$iracdes."_irac_ch4.fits\"> fits </a>";
		echo "<td><a href=\"".$iracdes."_irac_ch4.gif\"> gif </a></tr>";
		echo "<tr><td>24um: <td><a href=\"".$iracdes."_mips24.fits\"> fits </a>";
		echo "<td><a href=\"".$iracdes."_mips24.gif\"> gif </a></tr>";
		echo "<tr><td>70um: <td><a href=\"".$iracdes."_mips70.fits\"> fits </a>";
		echo "<td><a href=\"".$iracdes."_mips70.gif\"> gif </a></tr>";
		echo "<tr><td>160um: <td><a href=\"".$iracdes."_mips160.fits\"> fits </a>";
		echo "<td><a href=\"".$iracdes."_mips160.gif\"> gif </a></tr>";
		echo "<tr><td> SED: <td><a href=\"".$iracdes.".png\"> png </a>";
		echo "<td> <a href=\"".$iracdes.".cps\"> cps </a>";
		echo "<td><a href=\"".$iracdes.".txt\"> txt </a>";
		echo "</tr></table></td>";

		echo "<td><table>";
		echo "<tr><td><a href=\"http://simbad.u-strasbg.fr/simbad/sim-coo?CooEpoch=2000&Coord=".$db[16]." ".$db[17]."&submit=submit query&Radius.unit=arcsec&CooEqui=2000&CooFrame=FK5&Radius=3\"> SIMBAD: ".$db[$headindex['other_id']]."</a>";
		echo "<tr><td><a href=\"http://nedwww.ipac.caltech.edu/cgi-bin/nph-objsearch?in_csys=Equatorial&in_equinox=J2000.0&lon=".$db[16]."d&lat=+".$db[17]."d&radius=.05&search_type=Near+Position+Search\">  NED  </a>";
		echo "<tr><td><a href=\"http://irsa.ipac.caltech.edu/cgi-bin/Radar/nph-estimation?objstr=".$db[16]."+".$db[17]."&submit=Get+Inventory&mode=cone&radius=3&radunits=arcsec&mission=All&irsa=IRSA+and+Vizier\"> IRSA/Vizier Query (3\") </a>";
		echo "<tr><td><a href=\"http://heasarc.gsfc.nasa.gov/db-perl/W3Browse/w3query.pl?tablehead=name%253D%2540All%255FArchives%2526&Coordinates=Equatorial%3A+R.A.+Dec&Entry=".$db[16].",".$db[17]."&maxrows=100&Equinox=2000&Radius=0.05&Radius_unit=arcmin&requery=Reissue+Query&displaymode=Display\"> HEASARC </a>";
		echo "<tr><td><a href=\"http://archive.stsci.edu/cgi-bin/genlinks_search.cgi?target=".$db[16].",".$db[17]."&radius_acs=.1&radius_wfpc2=.1&radius_iue=.1&radius_foc=.1&radius_wfpc1=.1&radius_nicmos=.1&radius_stis=.1\">  MAST (3')  </a>";
		echo "<tr><td><a href=\"http://cdsads.u-strasbg.fr/cgi-bin/nph-abs_connect?db_key=AST&db_key=PRE&qform=AST&arxiv_sel=astro-ph&arxiv_sel=cond-mat&arxiv_sel=cs&arxiv_sel=gr-qc&arxiv_sel=hep-ex&arxiv_sel=hep-lat&arxiv_sel=hep-ph&arxiv_sel=hep-th&arxiv_sel=math&arxiv_sel=math-ph&arxiv_sel=nlin&arxiv_sel=nucl-ex&arxiv_sel=nucl-th&arxiv_sel=physics&arxiv_sel=quant-ph&arxiv_sel=q-bio&sim_query=YES&ned_query=YES&aut_logic=OR&obj_logic=OR&author=&object=".$db[16]."+".$db[17]."%3A+.0028&start_mon=&start_year=&end_mon=&end_year=&ttl_logic=OR&title=&txt_logic=OR&text=&nr_to_return=100&start_nr=1&jou_pick=ALL&ref_stems=&data_and=ALL&group_and=ALL&start_entry_day=&start_entry_mon=&start_entry_year=&end_entry_day=&end_entry_mon=&end_entry_year=&min_score=&sort=SCORE&data_type=SHORT&aut_syn=YES&ttl_syn=YES&txt_syn=YES&aut_wt=1.0&obj_wt=1.0&ttl_wt=0.3&txt_wt=3.0&aut_wgt=YES&obj_wgt=YES&ttl_wgt=YES&txt_wgt=YES&ttl_sco=YES&txt_sco=YES&version=1\"> ADS search (10\") </a>";
		echo "</tr></table></td>";

		if ($db[131] == "null") {
				echo "<td width=100> no MACHO </td>";
		} else {
				echo "<td><table><tr><td><a href=\"http://store.anu.edu.au:3001/cgi-bin/fts.pl?F.T.S=".$fts."&Action=Submit\"> lightcurve </a>";
#				echo "<td><tr> DB131: $db[131]  FTS: $fts";
				echo "<tr><td><a href=\"".$fts.".txt\"> txt </a>";
				echo "<tr><td><a href=\"macho.php?fts=$fts\"> Plot </a></table></td>";
		}
		for ($i=0; $i<$numfields; $i++) {
				if ($header[$i] == "racDesignation") {
								echo "<td>".$db[$i]."</td>";
						} elseif ($header[$i] == "notes" ) {
								echo "<td><table><tr><td>General: $db[$i]</td></tr>
										<tr><td>Model: $db[161]</td></tr>
										<tr><td>Location: $db[117]</table></td>";
						} elseif ($header[$i] == "RA") {
								echo "<td><table width=\"120\"><tr><td> RA: $db[16] </td></tr>
										<tr><td> Dec: $db[17] </td></tr></table></td>";
						} elseif ($header[$i] == "type") {
								switch ($db[$i]) {
										case 1: 
												echo "<td> Post-AGB (1) </td>"; 
												break;
										case 2: 
												echo "<td> Weak Post-AGB (2) </td>";
												break;
										case 3: 
												echo "<td> Warm Post-AGB (3) </td>";
												break;
										case 4: 
												echo "<td> B[e] star? Weak candidate PAGB (4) </td>";
												break;
										case 5: 
												echo "<td> AGB with dust excess (5) </td>";
												break;
										case 6: 
												echo "<td> XAGB? (6) </td>";
												break;
										case 7: 
												echo "<td> B[e] star (7) </td>";
												break;
										case 8: 
												echo "<td> Galaxy (8) </td>";
												break;
										case 9: 
												echo "<td> Unknown (9) </td>";
												break;
										case 10: 
												echo "<td> Odd-shape RCB or RV Tauri (10) </td>";
												break;
										case 11: 
												echo "<td> 5um peak RCBs (11) </td>";
												break;
										case 12: 
												echo "<td> Strong dust excess AGB fit by 2dust (12) </td>";
												break;
										case 13: 
												echo "<td> PNe (13) </td>";
												break;
										case 14: 
												echo "<td> Luminous Object (14) </td>";
												break;
										case 15: 
												echo "<td> Error - category removed (15) </td>";
												break;
										case 16: 
												echo "<td> Literature-selected post-AGB (16) </td>";
												break;
										case 17: 
												echo "<td> Post-AGB near SFR (17) </td>";
												break;
								}
						}
		}
		if ($db[142] == "null") {
				echo "<td> no model match </td>";
		} else {
				$chi2 = sprintf("%.3f",$db[150]);
				echo "<td><table width=\"100%\"><tr><td>Model: $db[142]</td></tr>
						<tr><td>Temp: $db[144]</td></tr>
						<tr><td>Tau: $db[145]</td></tr>
						<tr><td>GeomA,B: $db[146],$db[147]</td></tr>
						<tr><td>DustTemp: $db[158]</td></tr>
						<tr><td>Chi2: $chi2</td></tr>
						<tr><td>Chemistry: $db[159]</td></tr>
						<tr><td>Inclination: $db[143]</td></tr>
						</table></td>";
		}
		$flux = sprintf("%.3e",$db[138]) ; 
		$lum = sprintf("%.2f",$db[140]) ;
		$modellum = sprintf("%.2f",$db[155]);
		$mbol = sprintf("%.3f",$db[139]);
		$modmbol = sprintf("%.3f",$db[156]);
		$modmeas = sprintf("%.3f",$db[157]);
		echo "<td><table><tr><td> Flux: $flux </td></tr>
				<tr><td>Luminosity:$lum </td></tr>
				<tr><td>Model Lum: $modellum </td></tr>
				<tr><td>Mbol:$mbol </td></tr>
				<tr><td>Model Mbol:$modmbol </td></tr>
				<tr><td>Model/Meas: $modmeas </table></td>";
		echo "</tr>\n";
		$linenum++;
}
echo "</table>\n";
?>
</body>
</html>
