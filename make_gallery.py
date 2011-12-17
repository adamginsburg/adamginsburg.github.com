import os

outf = open('gallery.htm','w')

print >>outf,"""
<html>
<head>
<meta http-equiv="Content-Language" content="en-us">
<meta name="description" content="Adam Ginsburg - Astronomy research at the University of Colorado Center for Astrophysics and Space Astronomy">
<meta name="keywords" content="Keflavich, Ginsburg, Adam Ginsburg, Ginsburglar, Adam Gabriel Ginsburg, Adam Gabriel Stein Ginsburg">
<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">
<link rel="stylesheet" type="text/css" href="style.css">
<link rel="icon" type="image/gif" href="favicon8.ico">
<title>Adam Ginsburg's Gallery</title>
<center>
<font size="6">Picture Gallery</font>
<table width=800><tr><td>
<center>
"""

for root,dirs,files in os.walk('./'):
    for exclude in ('w5','jcmt','orion','sketch','pcygni','iras','p491','smt2','apextract','lab3'):
        if exclude in root: 
            root = '' # can't continue @ higher level, but that's what this is trying to do
    if "thumbs" in root:
        for fn in files:
            for exclude in ('Google','logo','ds9','whitesands','coronograph','spicam','class','thomas'):
                if exclude in fn: fn = ''
            if "jpg" in fn or "png" in fn or "JPG" in fn:
                print >>outf,"<a href='%s/%s'> <img src=%s/%s> </a>" % (root.replace("/thumbs",""),fn.replace("_tn",""),root,fn)

print >>outf,"""

<br>
<?php include 'navbar.php';?>
</td></tr></table>
<script type="text/javascript">
var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
</script>
<script type="text/javascript">
var pageTracker = _gat._getTracker("UA-6253200-1");
pageTracker._trackPageview();
</script>
</body>

</html>
"""

outf.close()
