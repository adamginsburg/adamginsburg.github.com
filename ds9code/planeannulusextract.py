#!/usr/bin/python
################################################################################
# Use:  ./annulusextractds9.py [filename] [region]
# annulusextractds9 is a script that sums a circular aperture in each plane of
# a data cube, then sums an aperture of equal area (if the region type is a
# circle) or outer annulus size (if an annulus region is used) in that same 
# plane.  The outer sum is subtracted from the inner sum, presumably creating
# a background-subtracted relative flux value for that point.  The output format
# is [image number] [value] for each flux: if piped to DS9's $plot macro, it 
# will generate a plot.
# For DS9 Analysis Tool implementation, see "annulustools.ds9"
# For a different output format (fits) for multiple apertures, use
# annulusextract.py
# 
################################################################################
import re
import sys
import os
os.environ['NUMERIX']='numpy'
import pyfits
import numpy
#import PyGuide
#from gridtocircle import circmask

#Function Definitions
def core(im,x,y,r):
    x=float(x)
    y=float(y)
    r=float(r)
    rad = radial(im,x,y)
    mask = ( rad < r )
    sumline = (mask*im).sum()
    return sumline

def radial(im,x,y):
    ysize,xsize = im.shape[0:2]
    yarr,xarr = numpy.indices([ysize,xsize])
    rarr = numpy.sqrt((xarr-x)**2+(yarr-y)**2)
    return rarr

#open fits file: assumes CUBE with "correct" orientation (x,y,velocity)
fitsfile = sys.argv[1]
fitsdata = pyfits.open(fitsfile)
image = numpy.asarray(fitsdata[0].data,dtype='float32')
hdulist = pyfits.HDUList()

regionfile = sys.argv[2].lstrip('@')
if os.path.exists(regionfile):
    regiondata = open(regionfile,'r')
else:
    regiondata = [regionfile]


#MAIN
#ccdinf = PyGuide.CCDInfo(0,0,1) #bias,readnoise,gain: assume no noise or bias
rtype,xcen,ycen,rad,rad2=[],[],[],[],[]
i=0
for line in regiondata:
    for subline in line.split(";"):
        larr = re.split('[(), ]',subline.rstrip())
        rtype.append(larr[0])
        if rtype[i] == '#' or rtype[i] == 'global' or rtype[i] == 'physical' or rtype[i] == 'image':
            i=i+1
            xcen.append('')
            ycen.append('')
            rad.append('')
            rad2.append('')
            continue
        elif rtype[i] == 'annulus':
            xcen.append(float(larr[1]))
            ycen.append(float(larr[2]))
            rad.append(float(larr[3]))
            rad2.append(float(larr[4]))
            innerradius = rad[i]
            outerradius = rad2[i]
            (newxcen,newycen)=[outerradius,outerradius]
            subimage = image[int(ycen[i]-outerradius):int(ycen[i]+outerradius),int(xcen[i]-outerradius):int(xcen[i]+outerradius)]
        elif rtype[i] == 'circle':
            xcen.append(float(larr[1]))
            ycen.append(float(larr[2]))
            rad.append(float(larr[3]))
            rad2.append(float(larr[3] * numpy.sqrt(2)))
            outerrad = rad[i]
            subimage = image[int(ycen[i]-outerrad):int(ycen[i]+outerrad),int(xcen[i]-outerrad):int(xcen[i]+outerrad)]
#            center = PyGuide.centroid(subimage,None,None,[rad[i],rad[i]],rad[i],ccdinf,thresh=1,verbosity=0,smooth=0)
#            if center.isOK:
#                innerradius = PyGuide.starShape(subimage,None,center.xyCtr,rad[i]).fwhm
#                outerradius = innerradius * numpy.sqrt(2)
#                (newxcen,newycen)=center.xyCtr
#                print "%s  %s" % (str(center.xyCtr),str(center.xyErr))
#            else: 
#                print "Error: %s.  Using the point you selected instead of the star center." % str(center.msgStr)
            innerradius = 0 #rad[i]
            outerradius = outerrad
            (newxcen,newycen)=[outerrad,outerrad]
#            if float(rad2[i]) > float(rad[i]):
#                outerrad = rad2[i]
#            else: 
#                outerrad = float(rad[i])*numpy.sqrt(2)
        else:
            print "Error: region type is not recognized (or possibly you are specifying an unrecognized coordinate system)"
#        subimage = image[:,ycen[i]-rad[i]:ycen[i]+rad[i],xcen[i]-rad[i]:xcen[i]+rad[i]]
        #inner = core(subimage,newxcen,newycen,innerradius)
        inner = 0
        equalarea = core(subimage,newxcen,newycen,outerradius) - inner
        vspec = inner - equalarea
        npixinner = numpy.sum(radial(subimage,newxcen,newycen)<innerradius)
        npixouter = numpy.sum(radial(subimage,newxcen,newycen)<outerradius) - npixinner
#        print "inner radius: %f outer radius: %f" % (innerradius,outerradius)
        print "diff: %f  inner: %f  outer: %f npixouter: %d npixinner: %d" % (vspec,inner,equalarea,npixouter,npixinner) 
        break
        i=i+1






