<?php

//
// 
// If you see this text in your browser, it means PHP scripts are not
// enabled on this web server.  Consult the internet or your local system
// administrator to enable PHP scripting.
//
//

$paperFile = "papers";
$logFile = "dregs.log";
$listManager = "listmanager.php";
$article = $_POST["article"];
$ipOfSubmitter=$_SERVER["REMOTE_ADDR"];
 
if ((!isset($_POST["submit"])) and (!isset($_POST["submitcheck"])))  
  { // if page is not submitted, show the form
  ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Astro-ph Coffee at Boulder</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<!--
<meta name="keywords" content="astro-ph, arxiv, astronomy, Boulder, coffee" />
<meta name="author" content="Boulder Astronomy" />-->
<link rel="stylesheet" type="text/css" href="style.css" />
</head>


<body>
<h2>Astro-ph Coffee suggested papers for 2010-02-17</h2>
<div class="extras">
<div class="submission">
  
  <form method="post" action="<?php $result = exec('/Users/adam/Sites/ac2/runcoffee.py &> /Users/adam/logs/ac2/astrocoffee.log'); echo $result; echo $PHP_SELF;?>">
  Submit a URL or arXiv-ID:<input type="text" size="12" maxlength="128" name="article">
    <input type="submit" value="submit" name="submit">
    <br><br>
    <input type="submit" value="check submissions file" name="submitcheck">
  </form>
 
</div>
</div>
<p>Astro-ph Coffee is held at ALWAYS on Alldays in the
 reading room.  
<p> 12 Feb 2010 </p>
<div id="ptitle"><a href="http://arxiv.org/abs/1002.2475"> The 6-GHz methanol multibeam maser catalogue I: Galactic Centre region,  longitudes 345 to 6</a></div>
<div id="pauthors"> <a href="http://arxiv.org/find/astro-ph/1/au:+Caswell_J/0/1/0/all/0/1">J. L. Caswell</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Fuller_G/0/1/0/all/0/1">G. A. Fuller</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Green_J/0/1/0/all/0/1">J. A. Green</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Avison_A/0/1/0/all/0/1">A. Avison</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Breen_S/0/1/0/all/0/1">S. L. Breen</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Brooks_K/0/1/0/all/0/1">K. J. Brooks</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Burton_M/0/1/0/all/0/1">M. G. Burton</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Chrysostomou_A/0/1/0/all/0/1">A. Chrysostomou</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Cox_J/0/1/0/all/0/1">J. Cox</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Diamond_P/0/1/0/all/0/1">P. J. Diamond</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Ellingsen_S/0/1/0/all/0/1">S. P. Ellingsen</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Gray_M/0/1/0/all/0/1">M. D. Gray</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Hoare_M/0/1/0/all/0/1">M. G. Hoare</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Masheder_M/0/1/0/all/0/1">M. R. W. Masheder</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+McClure_Griffiths_N/0/1/0/all/0/1">N. M. McClure-Griffiths</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Pestalozzi_M/0/1/0/all/0/1">M. R. Pestalozzi</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Phillips_C/0/1/0/all/0/1">C. J. Phillips</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Quinn_L/0/1/0/all/0/1">L. Quinn</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Thompson_M/0/1/0/all/0/1">M. A. Thompson</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Voronkov_M/0/1/0/all/0/1">M. A. Voronkov</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Walsh_A/0/1/0/all/0/1">A. J. Walsh</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Ward_Thompson_D/0/1/0/all/0/1">D. Ward-Thompson</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Wong_McSweeney_D/0/1/0/all/0/1">D. Wong-McSweeney</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Yates_J/0/1/0/all/0/1">J. A. Yates</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Cohen_R/0/1/0/all/0/1">R. J. Cohen</a></div>
<div id="pabstract"> We have conducted a Galactic plane survey of methanol masers at 6668 MHz using a 7-beam receiver on the Parkes telescope. Here we present results from the first part, which provides sensitive unbiased coverage of a large region around the Galactic Centre. Details are given for 183 methanol maser sites in the longitude range 345$^{\circ}$ through the Galactic Centre to 6$^{\circ}$. Within 6$^{\circ}$ of the Centre, we found 88 maser sites, of which more than half (48) are new discoveries. The masers are confined to a narrow Galactic latitude range, indicative of many sources at the Galactic Centre distance and beyond, and confined to a thin disk population; there is no high latitude population that might be ascribed to the Galactic Bulge. <br />Within 2$^{\circ}$ of the Galactic Centre the maser velocities all lie between -60 and +77 \kms, a range much smaller than the 540 \kms range observed in CO. Elsewhere, the maser with highest positive velocity (+107 \kms) occurs, surprisingly, near longitude 355$^{\circ}$ and is probably attributable to the Galactic bar. The maser with the most negative velocity (-127 \kms) is near longitude 346$^{\circ}$, within the longitude-velocity locus of the near side of the `3-kpc arm'. It has the most extreme velocity of a clear population of masers associated with the near and far sides of the 3-kpc arm. Closer to the Galactic Centre the maser space density is generally low, except within 0.25 kpc of the Centre itself, the `Galactic Centre Zone', where it is 50 times higher, which is hinted at by the longitude distribution, and confirmed by the unusual velocities. </div>
<p></p>
<p> 15 Feb 2010 </p>
<div id="ptitle"><a href="http://arxiv.org/abs/1002.2946"> Direct observation of a sharp transition to coherence in Dense Cores</a></div>
<div id="pauthors"> <a href="http://arxiv.org/find/astro-ph/1/au:+Pineda_J/0/1/0/all/0/1">Jaime E. Pineda</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Goodman_A/0/1/0/all/0/1">Alyssa A. Goodman</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Arce_H/0/1/0/all/0/1">H&#xe9;ctor G. Arce</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Caselli_P/0/1/0/all/0/1">Paola Caselli</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Foster_J/0/1/0/all/0/1">Jonathan B. Foster</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Myers_P/0/1/0/all/0/1">Philip C. Myers</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Rosolowsky_E/0/1/0/all/0/1">Erik W. Rosolowsky</a></div>
<div id="pabstract"> We present NH3 observations of the B5 region in Perseus obtained with the Green Bank Telescope (GBT). The map covers a region large enough (~11'x14') that it contains the entire dense core observed in previous dust continuum surveys. The dense gas traced by NH3(1,1) covers a much larger area than the dust continuum features found in bolometer observations. The velocity dispersion in the central region of the core is small, presenting subsonic non-thermal motions which are independent of scale. However, it is thanks to the coverage and high sensitivity of the observations that we present the detection, for the first time, of the transition between the coherent core and the dense but more turbulent gas surrounding it. This transition is sharp, increasing the velocity dispersion by a factor of 2 in less than 0.04 pc (the 31" beam size at the distance of Perseus, ~250 pc). The change in velocity dispersion at the transition is ~3 km/s/pc. The existence of the transition provides a natural definition of dense core: the region with nearly-constant subsonic non-thermal velocity dispersion. From the analysis presented here we can not confirm nor rule out a corresponding sharp density transition. </div>
<p></p>
<p> 11 Feb 2010 </p>
<div id="ptitle"><a href="http://arxiv.org/abs/1002.2349"> Electron temperature anisotropy in an expanding plasma: Particle-in-Cell  simulations</a></div>
<div id="pauthors"> <a href="http://arxiv.org/find/physics/1/au:+Camporeale_E/0/1/0/all/0/1">Enrico Camporeale</a>,  <a href="http://arxiv.org/find/physics/1/au:+Burgess_D/0/1/0/all/0/1">David Burgess</a></div>
<div id="pabstract"> We perform fully-kinetic particle-in-cell simulations of an hot plasma that expands radially in a cylindrical geometry. The aim of the paper is to study the consequent development of the electron temperature anisotropy in an expanding plasma flow as found in a collisionless stellar wind. Kinetic plasma theory and simulations have shown that the electron temperature anisotropy is controlled by fluctuations driven by electromagnetic kinetic instabilities. In this study the temperature anisotropy is driven self-consistently by the expansion. While the expansion favors an increase of parallel anisotropy ($T_\parallel&gt;T_\perp$), the onset of the firehose instability will tend to decrease it. We show the results for a supersonic, subsonic, and static expansion flows, and suggest possible applications of the results for the solar wind and other stellar winds. </div>
<p></p>
<p> 12 Feb 2010 </p>
<div id="ptitle"><a href="http://arxiv.org/abs/1002.2475"> The 6-GHz methanol multibeam maser catalogue I: Galactic Centre region,  longitudes 345 to 6</a></div>
<div id="pauthors"> <a href="http://arxiv.org/find/astro-ph/1/au:+Caswell_J/0/1/0/all/0/1">J. L. Caswell</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Fuller_G/0/1/0/all/0/1">G. A. Fuller</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Green_J/0/1/0/all/0/1">J. A. Green</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Avison_A/0/1/0/all/0/1">A. Avison</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Breen_S/0/1/0/all/0/1">S. L. Breen</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Brooks_K/0/1/0/all/0/1">K. J. Brooks</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Burton_M/0/1/0/all/0/1">M. G. Burton</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Chrysostomou_A/0/1/0/all/0/1">A. Chrysostomou</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Cox_J/0/1/0/all/0/1">J. Cox</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Diamond_P/0/1/0/all/0/1">P. J. Diamond</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Ellingsen_S/0/1/0/all/0/1">S. P. Ellingsen</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Gray_M/0/1/0/all/0/1">M. D. Gray</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Hoare_M/0/1/0/all/0/1">M. G. Hoare</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Masheder_M/0/1/0/all/0/1">M. R. W. Masheder</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+McClure_Griffiths_N/0/1/0/all/0/1">N. M. McClure-Griffiths</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Pestalozzi_M/0/1/0/all/0/1">M. R. Pestalozzi</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Phillips_C/0/1/0/all/0/1">C. J. Phillips</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Quinn_L/0/1/0/all/0/1">L. Quinn</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Thompson_M/0/1/0/all/0/1">M. A. Thompson</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Voronkov_M/0/1/0/all/0/1">M. A. Voronkov</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Walsh_A/0/1/0/all/0/1">A. J. Walsh</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Ward_Thompson_D/0/1/0/all/0/1">D. Ward-Thompson</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Wong_McSweeney_D/0/1/0/all/0/1">D. Wong-McSweeney</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Yates_J/0/1/0/all/0/1">J. A. Yates</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Cohen_R/0/1/0/all/0/1">R. J. Cohen</a></div>
<div id="pabstract"> We have conducted a Galactic plane survey of methanol masers at 6668 MHz using a 7-beam receiver on the Parkes telescope. Here we present results from the first part, which provides sensitive unbiased coverage of a large region around the Galactic Centre. Details are given for 183 methanol maser sites in the longitude range 345$^{\circ}$ through the Galactic Centre to 6$^{\circ}$. Within 6$^{\circ}$ of the Centre, we found 88 maser sites, of which more than half (48) are new discoveries. The masers are confined to a narrow Galactic latitude range, indicative of many sources at the Galactic Centre distance and beyond, and confined to a thin disk population; there is no high latitude population that might be ascribed to the Galactic Bulge. <br />Within 2$^{\circ}$ of the Galactic Centre the maser velocities all lie between -60 and +77 \kms, a range much smaller than the 540 \kms range observed in CO. Elsewhere, the maser with highest positive velocity (+107 \kms) occurs, surprisingly, near longitude 355$^{\circ}$ and is probably attributable to the Galactic bar. The maser with the most negative velocity (-127 \kms) is near longitude 346$^{\circ}$, within the longitude-velocity locus of the near side of the `3-kpc arm'. It has the most extreme velocity of a clear population of masers associated with the near and far sides of the 3-kpc arm. Closer to the Galactic Centre the maser space density is generally low, except within 0.25 kpc of the Centre itself, the `Galactic Centre Zone', where it is 50 times higher, which is hinted at by the longitude distribution, and confirmed by the unusual velocities. </div>
<p></p>
<p> 5 Feb 2010 </p>
<div id="ptitle"><a href="http://arxiv.org/abs/1002.1115"> Extinction toward the Compact HII Regions G-0.02-0.07</a></div>
<div id="pauthors"> <a href="http://arxiv.org/find/astro-ph/1/au:+Mills_E/0/1/0/all/0/1">E.A. Mills</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Morris_M/0/1/0/all/0/1">M.R. Morris</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Lang_C/0/1/0/all/0/1">C.C. Lang</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Cotera_A/0/1/0/all/0/1">A. Cotera</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Dong_H/0/1/0/all/0/1">H. Dong</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Wang_Q/0/1/0/all/0/1">Q.D. Wang</a>,  <a href="http://arxiv.org/find/astro-ph/1/au:+Stolovy_S/0/1/0/all/0/1">S.R. Stolovy</a></div>
<div id="pabstract"> The four HII regions in the Sgr A East complex: A, B, C, and D, represent evidence of recent massive star formation in the central ten parsecs. Using Paschen-alpha images taken with HST and 8.4 GHz VLA data, we construct an extinction map of A-D, and briefly discuss their morphology and location. </div>
<p></p>
</body>
</html>
<? // If check-form _was_ submitted, display this instead:
  } elseif (isset($_POST["submitcheck"])) {
  echo 'Loading article list manager...<br>';
  echo '<META HTTP-EQUIV=Refresh CONTENT="1;'.$listManager.'">';
 
// If submit-form _was_ submitted, display this instead:
} elseif (isset($_POST["submit"])) {
  $minlength = 5;
  $result=exec('/Users/adam/Sites/ac2/force_runcoffee.py &> /Users/adam/logs/ac2/astrocoffee.log'); 
  echo "<p> Result of runcoffee command: ";
  echo $result; 
  echo "<p>You submitted ".$article.".</p>";
 
  if (strlen($article)>$minlength) {
    $f = fopen($paperFile,"a") or die("can't open file: ".$paperFile);
    fwrite($f, "\n".$article);
    fclose($f);
    echo "<p>Your sumission was successfully added to the list. </p>";
    echo "<p>Thanks for advancing knowledge!</p>";
    echo "<p>It may be several minutes before the main page is updated.</p>";
    date_default_timezone_set('MST/-7.0');
    $str4log = date(DATE_ATOM)."	".$article."	".$ipOfSubmitter;
    $f2 = fopen($logFile,"a") or die("can`t open file: ".$logFile);
    fwrite($f2, $str4log."\n");
    fclose($f2);
    $nullRet = `python runcoffee.py > /dev/null &`;
  } else {
    echo "This is shorter than the minimum valid string length (".$minlength.").";
    echo "Thus your submission was not added to the papers list.";
  }
 
} else {
  echo "you should not have reached this point!";
}
?>
<p><a href="astro_coffee.php">Go back</a> to the main page.</p>
