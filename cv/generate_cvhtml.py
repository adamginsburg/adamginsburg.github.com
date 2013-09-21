# -*- coding: utf-8 -*-

import dateutil.parser
import requests
import astropy.io.votable as votable
import os

def get_dev_key():

    ads_dev_key_filename = os.path.abspath(os.path.expanduser('~/.ads/dev_key'))

    if os.path.exists(ads_dev_key_filename):
        with open(ads_dev_key_filename, 'r') as fp:
            dev_key = fp.readline().rstrip()

        return dev_key

    if 'ADS_DEV_KEY' in os.environ:
        return os.environ['ADS_DEV_KEY']

    raise IOError("no ADS API key found in ~/.ads/dev_key")


response = requests.post('http://adslabs.org/adsabs/api/search/',
                         params={'q':'author:ginsburg, a','dev_key':get_dev_key(),
                                 'rows':200,
                                 'filter':'database:astronomy',
                                 'facet':'bibstem'})

J = response.json()

#result = requests.post("http://adsabs.harvard.edu/cgi-bin/nph-abs_connect?db_key=AST&db_key=PRE&qform=AST&arxiv_sel=astro-ph&arxiv_sel=cond-mat&arxiv_sel=cs&arxiv_sel=gr-qc&arxiv_sel=hep-ex&arxiv_sel=hep-lat&arxiv_sel=hep-ph&arxiv_sel=hep-th&arxiv_sel=math&arxiv_sel=math-ph&arxiv_sel=nlin&arxiv_sel=nucl-ex&arxiv_sel=nucl-th&arxiv_sel=physics&arxiv_sel=quant-ph&arxiv_sel=q-bio&sim_query=YES&ned_query=YES&adsobj_query=YES&aut_logic=OR&obj_logic=OR&author=ginsburg%2C+a&object=&start_mon=&start_year=2006&end_mon=&end_year=&ttl_logic=OR&title=&txt_logic=OR&text=&nr_to_return=200&start_nr=1&jou_pick=ALL&ref_stems=&data_and=ALL&group_and=ALL&start_entry_day=&start_entry_mon=&start_entry_year=&end_entry_day=&end_entry_mon=&end_entry_year=&min_score=&sort=SCORE&data_type=SHORT&aut_syn=YES&ttl_syn=YES&txt_syn=YES&aut_wt=1.0&obj_wt=1.0&ttl_wt=0.3&txt_wt=3.0&aut_wgt=YES&obj_wgt=YES&ttl_wgt=YES&txt_wgt=YES&ttl_sco=YES&txt_sco=YES&version=1&data_type=VOTABLE")
#import tempfile
#tf = tempfile.NamedTemporaryFile()
#tf.write(result)
#tf.flush()
#first_table = votable.parse(tf.name, pedantic=False).get_first_table()
#table = first_table.to_table()

fmt = u'''                <li><a class="norm" href="http://adsabs.harvard.edu/abs/{identifier}">{creator}</a> {month}, <b>{year}</b> {journal}
                <br>&nbsp;&nbsp;&nbsp;{title}'''

datalist = J['results']['docs']
#pubdates = [d['pubdate'] for d in datalist]
#sortorder = sorted(range(len(pubdates)), key=pubdates.__getitem__)

def format(data):
    #date = dateutil.parser.parse(data['pubdate']) 
    data['month'] = data['pubdate'][5:7] # date.month
    #data['year'] = date.year
    data['identifier'] = data['identifier'][0] if isinstance(data['identifier'],list) else data['identifier']
    data['title'] = data['title'][0] if isinstance(data['title'],list) else data['title']
    data['journal'] = data['pub'][0] if isinstance(data['pub'],list) else data['pub']
    data['author'] = ['<b>{}</b>'.format(x) if 'Ginsburg' in x and not '<b>' in x else x for x in data['author']]
    data['author'] = [x.replace("\\x","&#") for x in data['author']]
    data['creator'] = u"; ".join(data['author'])
    return data

import codecs

with codecs.open('generated.html','w',encoding='utf8') as outf:
    for data in datalist:
        print fmt.format(**format(data))

        print >>outf,fmt.format(**format(data))

print datalist[1]
