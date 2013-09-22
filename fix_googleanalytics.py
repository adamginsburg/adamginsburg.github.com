
old_uid = 'UA-6253200-1'
new_uid = 'UA-37306139-2'

tracking_script = """<script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-37306139-2']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

</script>"""

import os

for rootdir,dirname,flist in os.walk('.'):
    for fn in flist:
        if "htm" == fn[-3:] or 'html' == fn[-4:]:
            fullfn = os.path.join(rootdir,fn)
            with open(fullfn,'r') as f:
                data = f.read()
                if old_uid in data:
                    data = data.replace(old_uid,new_uid)
                    with open(fullfn,'w') as outf:
                        outf.write(data)
                    print "Fixed ",fullfn
                elif new_uid in data:
                    print "Already fixed: ",fullfn
                else:
                    print "No UA in ",fullfn
                    if "</html>" in data:
                        data = data.replace("</html>",tracking_script+"\n</html>")
                    with open(fullfn,'w') as outf:
                        outf.write(data)
