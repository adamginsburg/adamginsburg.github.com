<?php
#echo "<center>";
$links = array('Home'=>'index.htm', 'Research'=>'interests.htm', 'Teaching'=>'teaching.htm', 'Outreach'=>'outreach.htm','Software'=>'software.htm','Contact Me'=>'contact.htm','CV'=>'cv.htm','Site Map'=>'sitemap.htm', "Research Blog"=>"http://keflavich.github.io/blog/");
# 'About Me'=>'about.htm',
#$links = array('Home'=>'index.htm', 'Research'=>'interests.htm', 'Teaching'=>'teaching.htm', 'Outreach'=>'outreach.htm','Software'=>'software.htm','Contact Me'=>'contact.htm','About Me'=>'about.htm','CV'=>'cv.htm','Site Map'=>'sitemap.htm');
$leftbrace = "<span class=leftbraces>[</span>";
$rightbrace = "<span class=rightbraces>]</span>";
echo "<nav>";
echo "<ul>";
foreach ($links as $key => $value) {
    echo "<li><a class=navbar href=\"$value\">$key</a></li>";
}
echo "</ul>";
echo "</nav>";

#echo "</center>";

echo "<script type=\"text/javascript\">";
echo "var gaJsHost = ((\"https:\" == document.location.protocol) ? \"https://ssl.\" : \"http://www.\");";
echo "document.write(unescape(\"%3Cscript src='\" + gaJsHost + \"google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E\"));";
echo "</script>";
?>

