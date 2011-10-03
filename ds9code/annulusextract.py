#!/usr/bin/python
#sample calls:
#./annulusextract.py oriha1.fits target_annuli.reg testcircles
#%run annulusextract.py oriha1.fits target_annuli.reg halpatargetannuli
#%run annulusextract.py trapezium.fits trapeziumtargetcircles.reg trapeziumcircles
import re
import sys
import os
os.environ['NUMERIX']='numpy'
import pyfits
import numpy
import pylab
import numdisplay
import matplotlib
import gridtocircle
from gridtocircle import circmask
import PyGuide
from astLib import astWCS
import coords

#global: don't recreate on each call

#Function Definitions
def core(im,x,y,r):
    x=float(x)
    y=float(y)
    r=float(r)
    size = im.shape[0]
    sumline = numpy.zeros(size)
    for i in xrange(size):
#        rad = radial(im[i,:,:],x,y)
#        mask = ( rad < r )
        mask = circmask(x,y,r,im.shape[1],im.shape[2])
        '''
        if i<2:
            numdisplay.open()
            numdisplay.display(mask.astype(float))
            numdisplay.close()
#            print "Displayed the mask for aperture at " + str(x) + "," + str(y) + " with radius " + str(r)
        '''
        sumline[i]=masksum(im[i,:,:],mask)
    return sumline

def radial(im,x,y):
    ysize,xsize = im.shape[0:2]
    yarr,xarr = numpy.indices([ysize,xsize])
#    r = numpy.sqrt((y-ysize/2.)**2+(x-xsize/2.)**2)
    rarr = numpy.sqrt((xarr-x)**2+(yarr-y)**2)
    #pylab.ioff()
    #pylab.imshow(r)
    return rarr

def masksum(im,mask):
    thesum = (im*mask).sum()
    return thesum

#open fits file: assumes CUBE with "correct" orientation (x,y,velocity)
#sample: ./annulusextract.py oriha1.fits target_annuli.reg testoutput
fitsfile = sys.argv[1]
fitsdata = pyfits.open(fitsfile)
image = numpy.asarray(fitsdata[0].data,dtype='float32')
imWCS = astWCS.WCS(fitsfile,0)
hdulist = pyfits.HDUList()

regionfile = sys.argv[2]
regiondata = open(regionfile,'r')

outputname = sys.argv[3]

#MAIN
ccdinf = PyGuide.CCDInfo(0,0,1) #bias,readnoise,gain: assume no noise or bias
rtype,xcen,ycen,rad,rad2=[],[],[],[],[]
i=0
pylab.ioff()
#os.system('rm vspec.eps')
for line in regiondata:
    larr = re.split('[(), ]',line.rstrip())
    rtype.append(larr[0])
    if rtype[i] == '#' or rtype[i] == 'global' or rtype[i] == 'physical' or rtype[i] == 'rcs' or rtype[i] == 'linear':
#        print "Skipping line " + line + " because rtype[i] is " + rtype[i] + " and i is " + str(i)
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
        print "Region type: " + str(rtype[i]) + " x,y: " + str(xcen[i]) + "," + str(ycen[i]) + " radii: " + str(rad[i]) + "," + str(rad2[i])
    elif rtype[i] == 'circle':
        xcen.append(float(larr[1]))
        ycen.append(float(larr[2]))
        rad.append(float(larr[3]))
        rad2.append(float(larr[3] * numpy.sqrt(2)))
        print "Region type: " + str(rtype[i]) + " x,y: " + str(xcen[i]) + "," + str(ycen[i]) + " radius: " + str(rad[i])
    else:
        print "Error: region type is not recognized (or possibly you are specifying an unrecognized coordinate system)"
#        inner = core(image,xcen[i],ycen[i],rad[i])
#        equalarea = core(image,xcen[i],ycen[i],float(rad[i])*numpy.sqrt(2)) - inner
#        vspec = inner - equalarea
# DEBUG        print "Region type: " + rtype + " x,y: " + str(xcen) + "," + str(ycen) + " radii: " + str(rad) 

# DEBUG     print "subimage shape %s with input params rad: %s ycen: %s xcen: %s " % (subimage.shape,rad[i],ycen[i],xcen[i])
    if float(rad2[i]) > float(rad[i]):
        outerrad = rad2[i]
    else: 
        outerrad = float(rad[i])*numpy.sqrt(2)
#        subimage = image[:,ycen[i]-rad[i]:ycen[i]+rad[i],xcen[i]-rad[i]:xcen[i]+rad[i]]
    subimage = image[:,ycen[i]-outerrad:ycen[i]+outerrad,xcen[i]-outerrad:xcen[i]+outerrad]
#        center = PyGuide.centroid(subimage[0],None,None,[outerrad,outerrad],rad[i],ccdinf)
    center = PyGuide.centroid(subimage[0],None,None,[rad[i],rad[i]],rad[i],ccdinf,thresh=1,verbosity=0,smooth=0)
    if center.isOK:
        (newxcen,newycen)=center.xyCtr
        starshape = PyGuide.starShape(subimage[0],None,center.xyCtr,rad[i])
        if starshape.isOK:
            innerradius = starshape.fwhm
        else:
            print starshape
            print "Problem with inner radius calculation for the source at %s" % str(center.xyCtr)
            print "Real coordinates: %s " % coords.Position(imWCS.pix2wcs(center.xyCtr[0]+xcen[i]-outerrad,center.xyCtr[1]+ycen[i]-outerrad)).hmsdms()
            continue
        outerradius = innerradius * numpy.sqrt(2)
        error = None
#            print "%s  %s" % (str(center.xyCtr),str(center.xyErr))
    else: 
        print "Error: %s.  Using the point you selected instead of the star center." % str(center.msgStr)
        error = str(center.msgStr)
        (newxcen,newycen)=[outerrad,outerrad]
        innerradius = rad[i]
        outerradius = outerrad
    inner = core(subimage,newxcen,newycen,innerradius)
    equalarea = core(subimage,newxcen,newycen,outerradius) - inner
    vspec = inner - equalarea
    """ OLD VERSION
    subimage = image[:,ycen[i]-rad[i]:ycen[i]+rad[i],xcen[i]-rad[i]:xcen[i]+rad[i]]
    inner = core(subimage,rad[i],rad[i],rad[i])
    outerrad = float(rad[i])*numpy.sqrt(2)
    subimage2 = image[:,ycen[i]-outerrad:ycen[i]+outerrad,xcen[i]-outerrad:xcen[i]+outerrad]
    equalarea = core(subimage2,outerrad,outerrad,outerrad) - inner
    vspec = inner - equalarea
    """

    specarray = numpy.zeros([3,vspec.shape[0]])
    specarray[0,:]=vspec
    specarray[1,:]=inner
    specarray[2,:]=equalarea
    imxcen = newxcen+xcen[i]-outerrad
    imycen = newycen+ycen[i]-outerrad
    hdu = pyfits.ImageHDU(specarray)
    hdu.header.update('UXPOS',str(xcen[i]))
    hdu.header.update('UYPOS',str(ycen[i]))
    hdu.header.update('URADIUS',str(rad[i]))
    hdu.header.update('RA--DEG',imWCS.pix2wcs(imxcen,imycen)[0])
    hdu.header.update('DEC-DEG',imWCS.pix2wcs(imxcen,imycen)[1])
    hdu.header.update('RADEC',coords.Position(imWCS.pix2wcs(imxcen,imycen)).hmsdms())
    hdu.header.update('CXPOS',imxcen)
    hdu.header.update('CYPOS',imycen)
    hdu.header.update('CRADIUS',innerradius)
    hdu.header.update('ROW1',"Annulus-subtracted core extraction")
    hdu.header.update('ROW2',"Unsubtracted core extraction")
    hdu.header.update('ROW3',"Extracted Outer Annulus")
    if error is not None:
        hdu.header.update('ERROR',error)
    hdulist.append(hdu)

#    pylab.figure(1)
#    plottitle="%s at %2.2f , %2.2f" % (rtype[i],float(xcen[i]),float(ycen[i]))
#    pylab.title(plottitle)
#    plotlabel = "inner - outer"
#    pylab.plot(range(vspec.shape[0]),vspec,label=plotlabel,linestyle='steps' )
#    plotlabel = "inner" 
#    pylab.plot(range(vspec.shape[0]),inner,label=plotlabel,linestyle='steps' )
#    plotlabel = "outer"
#    pylab.plot(range(vspec.shape[0]),equalarea,label=plotlabel,linestyle='steps' )
#    pylab.draw()
#    pylab.legend(loc=0,prop=matplotlib.font_manager.FontProperties(size='x-small'))
#    pylab.savefig('%s%s.eps' % (outputname,str(i)))
#    os.system('cat %s%s.eps >> %s.eps' % (outputname,str(i),outputname))
#    os.system('echo "false 0 startjob pop" >> %s.eps' % outputname)
#    pylab.clf()
    i=i+1
hdulist.writeto('extractedplots_%s.fits' % outputname,output_verify='ignore',clobber=True)
del image
del hdulist
del fitsdata

'''
pylab.figure(1)
pylab.legend()
pylab.figure(2)
pylab.legend()
pylab.figure(3)
pylab.legend()
pylab.show()
'''






