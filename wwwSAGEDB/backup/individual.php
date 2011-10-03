
<html>
<head>
<title> LMC Post-AGB Database </title>
</head>
<body>
<?php 
$iracdes = $_REQUEST['filename'] ;
$twom = substr($iracdes,11,15);
$fts = $_REQUEST['fts'] ;
echo "<p>Individual Source: $iracdes </p><br>To view a larger version of the image, right-click on it and select 'View Image' in your browser.  To download the fits file, click on the image or right click and select 'Save link as...'.<br><br>"; 

echo "<a href=\"".$iracdes."_mcps.fits\"><img src=\"".$iracdes."_mcps.gif\" width=500 title=\"MCPS\"></a>";
echo "<a href=\"$twom"."_aJ.fits\"> <img src=\"$twom"."_aJ.gif\" width=500 title=\"2mass J\"> </a>";
echo "<a href=\"$twom"."_aH.fits\"> <img src=\"$twom"."_aH.gif\" width=500 title=\"2mass H\"> </a>";
echo "<a href=\"$twom"."_aK.fits\"> <img src=\"$twom"."_aK.gif\" width=500 title=\"2mass K\"> </a>";
echo "<a href=\"".$iracdes."_glm_mosaic_ch1_sage1_2s.fits\"><img src=\"".$iracdes."_glm_mosaic_ch1_sage1_2s.gif\" width=500 title=\"IRAC 3.6\" ></a>";
echo "<a href=\"".$iracdes."_glm_mosaic_ch2_sage1_2s.fits\"><img src=\"".$iracdes."_glm_mosaic_ch2_sage1_2s.gif\" width=500 title=\"IRAC 4.5\" ></a>";
echo "<a href=\"".$iracdes."_glm_mosaic_ch3_sage1_2s.fits\"><img src=\"".$iracdes."_glm_mosaic_ch3_sage1_2s.gif\" width=500 title=\"IRAC 5.8\" ></a>";
echo "<a href=\"".$iracdes."_glm_mosaic_ch4_sage1_2s.fits\"><img src=\"".$iracdes."_glm_mosaic_ch4_sage1_2s.gif\" width=500 title=\"IRAC 8.0\" ></a>";
echo "<a href=\"".$iracdes."_sage_mips24_montage32_rot_22jun06.cal.fits\"><img src=\"".$iracdes."_sage_mips24_montage32_rot_22jun06.cal.gif\" width=500 title=\"MIPS 24\" ></a>";
echo "<a href=\"".$iracdes."_sage_mips70_mipsenh_21jun06.cal.fits\"><img src=\"".$iracdes."_sage_mips70_mipsenh_21jun06.cal.gif\" width=500 title=\"MIPS 70\" ></a>";
echo "<a href=\"".$iracdes."_sage_mips160_mipsenh_21jun06.cal.fill_gap.modsub.fits\"><img src=\"".$iracdes."_sage_mips160_mipsenh_21jun06.cal.fill_gap.modsub.gif\" width=500 title=\"MIPS 160\" ></a>";
echo "<a href=\"".$iracdes.".txt\"><img src=\"".$iracdes.".png\" width=500 title=\"SED\" ></a>";
echo "<img src=\"macho.php?fts=$fts\" width=500 title=\"MACHO Light Curve\">";

?>
</body>
</html>
