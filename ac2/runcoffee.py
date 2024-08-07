#!/usr/bin/local/python
#
# HISTORY:
# --------
# 2010-02-03 11:44 IJC: Script to write Boulder astro-coffee page
# 2010-02-06 IJC: updated with PHP     
# 2010-02-08 18:30 IJC: Moved 'sleep' location to eat up less CPU time.
# 2010-02-09 11:25 IJC: Trying out a new format -- only update (1)
#                        when called and (2) when papers file is more
#                        recent than the PHP page.

import astroph, shutil, time

# Initialize variables
paperfile = 'papers'
mainfile = 'astro_coffee.php'
tempfile = 'astro_coffee_temp.php'

napTime = 10  # time, in seconds, to wait between web queries

# Check last-modified times:
paperTime = shutil.os.path.getmtime(paperfile)
webTime = shutil.os.path.getmtime(mainfile)

if paperTime>webTime:  # If list was updated, run the script!
    astroph.docoffeepage(paperfile,tempfile, sleep=napTime, php=True)
    shutil.copy(tempfile, mainfile)
    




