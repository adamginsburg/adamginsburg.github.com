"""
A module to generate HTML code using specified ArXiV file IDs.

The main function is:
   docoffee -- read in a file of arxiv IDs or interesting URLs, and
               write HTML code to specified file.

There is also a wrapper script, runcoffee.py, that 

This code created 2010-02-05 at UC Los Angeles by Ian J. Crossfield
and Nathaniel Ross.  Re-use or modification is allowed and encouraged,
so long as proper acknowledgement is made to the original author and
institution.
"""
# 2010-02-05 15:24 IJC: v0.1: URLs are valid IDs.  "Next Thursday"
# automatically calculated.
# 2010-02-06 16:15 IJC: v0.2: Adding submission field.
# 2010-02-08 18:04 IJC: v0.21: Added logfile
# 2010-02-09 11:08 IJC: v0.3: Using text files for header/footer
# 2010-02-11 09:30 IJC: v0.4: Using PHP article list manager.
# 2010-02-12 11:45 IJC: v0.41: Using multiple PHP headers (for day-of-week)

__version__ = '0.41'

class preprint:
    """Empty object container for preprints.
    """
    def __init__(self):
        return

def getnatureinfo(html):
    """Convert HTML from a Nature journal page to a preprint object."""
    # 2010-02-06 19:48 IJC: Created
    paper = preprint()

    flags = [['author', '<meta name="citation_authors" content="', '/>'], \
                 ['title', '<meta name="citation_title" content="','/>'], \
                 ['date', '<meta name="citation_date" content="','/>'], \
                 ['abstract', '<p class="lead">', '</p>']]

    for flag,key1,key2 in flags:
        thisval = getbetween(html, key1,key2)
        if thisval.find('<a href="/nature')>-1:
            thisval = thisval.replace('<a href="/nature', '<a href="http://www.nature.com/nature')
        elif thisval.find('<a href="/ngeo')>-1:
            thisval = thisval.replace('<a href="/ngeo', '<a href="http://www.nature.com/ngeo')
        exec("paper.%s = thisval" % flag )
        
    return paper

def getinfo(id, server='http://arxiv.org/abs/'):
    """Take an ArXiV ID and return the title, authors, abstract, submission date.

    INPUT:
       id -- (str): ArXiV ID (e.g. '1002.0504v1' or 1002.0504)
              _OR_
             (str) URL, from which TITLE tag will be extracted.
             
    OUTPUT:
       a preprint-class object.
    """
    # 2010-02-03 09:38 IJC: Created
    # 2010-02-05 15:08 IJC: Now gets title of HTML pages, too!  And
    # corrects "author" links.
    # 2010-02-09 11:05 IJC: Now do a better check for arxiv-IDs and valid URLs

    import urllib

    # Set up flags to use for finding desired text
    titleflags = ['title', '<h1 class="title"><span class="descriptor">Title:</span>', '</h1>']
    authorflags = ['author', '<div class="authors"><span class="descriptor">Authors:</span>', '</div>']
    abstractflags = ['abstract', '<span class="descriptor">Abstract:</span>', '</blockquote>']
    dateflags = ['date', '<div class="dateline">', '</div>']
    subjectflags = ['subject', '<td class="tablecell subjects">', '</td>']
    commentflags = ['comments', '<td class="tablecell comments">', '</td>']

    flags = [titleflags, authorflags, abstractflags, dateflags, \
                 subjectflags, commentflags]

    # Set up the ID and get the HTML code
    thispaper = preprint()
    id = str(id).strip()

    try:  # Check whether ID is a number
        idnum = float(id[0:9])
        isArxivNum = len(id)>=9
    except:
        isArxivNum = False

    if (id.find('http')>-1) or (id.find('www')>-1):  # seemingly valid URL
        urlpage = id
        try:
            u = urllib.urlopen(urlpage)
            html = u.read()
            u.close()
        except:
            return ["Could not reach URL %s" % urlpage]

        if urlpage.find('nature.com')>-1: # From Nature
            thispaper = getnatureinfo(html)
            thispaper.url = urlpage
            thispaper.id = ''

        else:
            thispaper.id = ''
            thispaper.date = 'Web article:'
            thispaper.url = urlpage
            thispaper.title = gethtmlkey(html, 'title')
            thispaper.author = ''
            thispaper.abstract = ''

    elif (id.find('astro-ph')>-1) or (isArxivNum): # arxiv paper, old or new
        urlpage = server+id
        try:
            u = urllib.urlopen(urlpage)
            html = u.read()
            u.close()
        except:
            return ["Could not reach URL %s" % urlpage]

        thispaper.id = id
        thispaper.url = urlpage
        for flag, f1,f2 in flags:
            ind0 = html.find(f1)
            ind1 = ind0 + len(f1)
            ind2 = html.find(f2,ind1)
            thistext = html[ind1:ind2]
            thistext = thistext.replace('\n', ' ')
            exec('thispaper.%s = thistext' % flag)
        thispaper.author = thispaper.author.replace('/find/','http://arxiv.org/find/')

    else: # not a valid input!
        return ["Not a valid input ID or URL: %s" % id ]
        

    # Search for the desired flags

    return thispaper

def readlist(filelist, sleep=60):
    """Get data for all papers with IDs or URLs specified.

    INPUT:
        filelist:  one of the following:
           (list) python list of IDs for astroph.getinfo
           (str) filename of an ascii file containing IDs

    OPTIONAL INPUT:
        sleep -- (float) number of seconds to wait between URL
                 requests, so aRxIv doesn't think you're a robot and
                 ban your connection.

    OUTPUT:
        a list of preprint-class objects
    """
    # 2010-02-03 10:06 IJC: Created
    # 2010-02-05 11:24 IJC: Added 'sleep' command
    import time
    papers = []
    
    if isinstance(filelist, list): 
        ids = filelist
    else: # Must be the name of a file to read:
        try:
            f = open(filelist, 'r')
            ids = f.readlines()
            f.close()
        except:
            print "Could not open file: %s" % filelist
            ids = ['']

    for id in ids:
        if len(id)>5:
            thispaper = getinfo(id)
            if isinstance(thispaper, preprint):
                papers.append(getinfo(id))
                time.sleep(sleep)

    return papers

def getbetween(string, key1, key2):
    """Return text in a string between two keys.##

    If both keys are not found, return the empty string ''
    """
    # 2010-02-06 19:43 IJC: Created
    ind1 = string.find(key1)
    ind2 = string.find(key2, ind1)

    if (ind1==-1) or (ind2==-1):
        return ''
    
    val = string[(ind1+len(key1)):ind2]
    return val


def gethtmlkey(html, key):
    """Pass in HTML code and extract the desired key.

    INPUT:
       html -- (list) or (str) of HTML code.
       key -- (str) html key, within which a value will be found.

    The method is: find first instance of "<key", and then the first
    instance of "</key" after it.  It is INSENSITIVE to capitalization.
    """
    # 2010-02-05 14:32 IJC: Created

    if isinstance(html, list):
        html = ''.join([line+'\n' for line in html])

    lowHTML = html.lower()  # in case tags are capitalized

    keyval = getbetween(lowHTML, '<'+key.lower(), '</'+key.lower())
    return keyval

def getnextthursday():
    """Return a string representation of the following Thursday's date.

    """
    # 2010-02-05 IJC: Created
    # 2010-02-12 IJC: Now set the name of the day of the week.
    import datetime

    # Get current date
    today = datetime.date.today()


    # Find number of days until next
    tilThursday = (-(today.weekday()-3)) % 7
    timeDiff = datetime.timedelta(days=tilThursday)
    nextThursday = today+timeDiff

    # Make time string
    datestring = nextThursday.strftime('%a, %b %d, %Y')

    return datestring

def makeheader(php=False):
    """Return the HTML header info.  If specified, use PHP and submission form."""
    # 2010-02-12 11:45 IJC: Now get correct Thursday
    #nextThursday = getnextthursday()
    import datetime
    today = datetime.date.today()

    if php:
        f = open('coffee_header_php.txt', 'r')
    else:
        f = open('coffee_header.txt', 'r')
        
    head = f.readlines()
    f.close()

    titleString = '<h2>Astro-ph Coffee suggested papers for %s</h2>\n'%today
    head.append(titleString)

    if php:
        f = open('coffee_header_php2.txt','r')
        head += f.readlines()
        f.close()

    head.append('<p>Astro-ph Coffee is held at ALWAYS on Alldays in the\n')
    head.append(' reading room.  \n')

    return head


def makefooter(php=False):
    """
    Return the HTML footer (list of str).  If called, append PHP scripting. 
    """
    # 2010-02-09 10:29 IJC: Updated to use coffee_footer_php.txt
    from time import localtime
    f= []
    yr,mo,day,hr,min,sec,wd,yd,ii = localtime()
#    f.append("<hr><p><a href='http://www.astro.Boulder.edu/~ianc/astroph.shtml'>astroph.py v%s</a>.  Updated %i/%02i/%02i %02i:%02i:%02i </p>" % \
#                 (__version__,yr,mo,day,hr,min,sec))
    f.append('</body>')
    f.append('</html>')
    foot = [line+'\n' for line in f]
    
    if php:
        f2 = open('coffee_footer_php.txt','r')
        phpfooter = f2.readlines()
        f2.close()
        foot = foot+phpfooter

    return foot
    
def makehtml(papers, php=False):
    """Return HTML code for a public ArXiV web page from paper list.

    INPUT:
       papers -- (list) python list of preprint-class objects.

    OPTIONAL INPUT:
       php -- (bool) whether to generate HTML containing PHP scripting
                for paper submissions


    OUTPUT:
       html -- HTML code for generating a web page
    """
    # 2010-02-03 10:13 IJC: Created
    # 2010-02-05 11:16 IJC: Added nextThursday call to automatically
    #                       update the next meeting.  Formated
    #                       last-updated string.  Changed intro string.
    # 2010-02-06 16:36 IJC: Adding PHP scripting.
    # 2010-02-12 11:45 IJC: Reverse papers order (most recent on top)

    import time
    
    # Generate header
    h = makeheader(php=php)

    # generate footer
    f = makefooter(php=php) 

    # Generate text from preprints
    body = []
    olddate = ''
    for paper in papers[::-1]:
        if isinstance(paper, preprint):
            date = paper.date.replace(')','').replace('(Submitted on ','')
            title = '<a href="%s">%s</a>' % (paper.url, paper.title)
            if olddate<>date:  
                body.append( '<p> %s </p>' % date)
            body.append( '<div id="ptitle">%s</div>' % title)
            body.append( '<div id="pauthors">%s</div>' % paper.author)
            body.append( '<div id="pabstract">%s</div>' % paper.abstract)
            body.append( '<p></p>')
            olddate = date

    body = [line+'\n' for line in body]

    # Concatenate everything together
    html = h + body + f

    return html

def docoffeepage(file, url, sleep=60, php=False):
    """Read in arxiv IDs from a specified ASCII file, and write HTML.

    INPUTS:
       file: (str) path of ASCII file with arxiv IDs 
       url:  (str) path of HTML file to write

    OPTIONAL INPUT:
        sleep -- (float) number of seconds to wait between URL
                 requests, so aRxIv doesn't think you're a robot and
                 ban your connection.
    """
    # 2010-02-03 10:43 IJC: Created.  
    # 2010-02-05 11:18 IJC: Updated comments and error-handling.  Added 'sleep' call.
    
    try: # Read in the papers
        papers = readlist(file,sleep=sleep)
        html = []
    except:
        html = ['Could not get the papers info']
        papers = []
        print 'Could not get the paper info'


    #try:
        # Generate the HTML
    html = makehtml(papers, php=php)

    #except:
    #    html.append(['Could not generate HTML'])
    #    print 'Could not generate HTML code'

    # Write the file
    #try:
    f = open(url, 'w')
    f.writelines(html)
    f.close()

    #except:
    #    print 'Could not write the HTML code to file "%s"' % url

    return
