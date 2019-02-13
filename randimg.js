/*
Random Image Link Script- By JavaScript Kit(http://www.javascriptkit.com) 
*/


function random_imglink(){
    var myimages=new Array()
    //specify random images below. You can have as many as you wish
    //myimages[1]="images/small/cuzco2_sm.jpg"
    //myimages[2]="images/small/cuzco_sm.jpg"
    //myimages[3]="images/small/huascaran_sm.jpg"
    //myimages[4]="images/small/huascaran_low_sm.jpg"
    myimages[5]="images/small/keyhole_sm.jpg"
    //myimages[6]="images/small/lookingoverholycross_sm.jpg"
    //myimages[7]="images/small/lovelandglissade_sm.jpg"
    //myimages[8]="images/small/lovelandgoggles_sm.jpg"
    //myimages[9]="images/small/mtelbert_sm.jpg"
    //myimages[10]="images/small/mtmassive_sm.jpg"
    //myimages[11]="images/small/mtrainier_sm.jpg"
    //myimages[12]="images/small/sky_sm.jpg"
    //myimages[13]="images/small/whitesandsjump_sm.jpg"
    //myimages[13]="images/QuandaryTelescope.jpeg"
    //http://127.0.0.1/images/QuandaryTelescope.jpeg
    myimages[14]="images/small/maunakea_onjcmt_sm.jpg"
    //myimages[15]="images/small/maunakeapeak_sm.jpg"
    //myimages[16]="images/small/mksunset1_sm.jpg"
    //myimages[17]="images/small/mksunset2_sm.jpg"
    //myimages[18]="images/small/mksunset3_sm.jpg"
    //myimages[19]="images/small/overI70_1_sm.JPG"
    //myimages[20]="images/small/overI70_2_sm.JPG"
    //myimages[12]="images/small/overI70_3_sm.JPG"
    //myimages[9]="images/small/overI70_4_sm.JPG"
    myimages[7]="images/gc/gc_winner_800x800.jpg"
    myimages[11]="images/gc/gc_alternate_800x800.jpg"
    //myimages[15]="images/berthoudjump.jpg"
    //myimages[6]="http://farm9.staticflickr.com/8181/8018405587_39fc025da3_c.jpg"
    myimages[21]="https://lh3.googleusercontent.com/-tryyxY3TFvY/VXST971sXyI/AAAAAAAAVqc/joyLVU61PLM/w2236-h1258-no/20150605_101014.jpg"
    myimages[22]="images/eso1711a.jpg"
    myimages[23]="https://www.aanda.org/images/stories/highlight/vol579-1/25073Bally.gif"


    //specify corresponding links below
    var imagelinks=new Array()
    imagelinks[1]=""//http://picasaweb.google.com/keflavich/PeruPiscoAndHuascaran"
    imagelinks[2]=""//http://picasaweb.google.com/keflavich/PeruPiscoAndHuascaran"
    //imagelinks[3]="http://picasaweb.google.com/keflavich/PeruPiscoAndHuascaran"
    //imagelinks[4]="http://picasaweb.google.com/keflavich/PeruPiscoAndHuascaran"
    imagelinks[5]=""//http://picasaweb.google.com/keflavich/LongsPeak"
    //imagelinks[6]="http://picasaweb.google.com/keflavich/MtMassiveAndHolyCross"
    //imagelinks[7]="http://picasaweb.google.com/keflavich/LovelandPass"
    imagelinks[8]=""//http://picasaweb.google.com/keflavich/LovelandPass"
    //imagelinks[9]="http://picasaweb.google.com/keflavich/ShavanoTabeguacheAndElbert"
    imagelinks[10]=""//http://picasaweb.google.com/keflavich/MtMassiveAndHolyCross"
    //imagelinks[11]="http://picasaweb.google.com/keflavich/Rainier"
    //imagelinks[12]="http://picasaweb.google.com/keflavich/PeruPiscoAndHuascaran"
    //imagelinks[13]="http://picasaweb.google.com/keflavich/ASTR3520WhiteSands"
    imagelinks[13]="http://www.flickr.com/photos/31267019@N06/sets/72157631612868259/"
    imagelinks[14]=""//http://picasaweb.google.com/keflavich/MaunaKeaObserving0708"
    //imagelinks[15]="http://picasaweb.google.com/keflavich/MaunaKeaObserving0708"
    imagelinks[16]=""//http://picasaweb.google.com/keflavich/MaunaKeaObserving0708"
    imagelinks[17]=""//http://picasaweb.google.com/keflavich/MaunaKeaObserving0708"
    imagelinks[18]=""//http://picasaweb.google.com/keflavich/MaunaKeaObserving0708"
    imagelinks[19]=""//http://picasaweb.google.com/keflavich/SnowshoeingAboveI70"
    imagelinks[20]=""//http://picasaweb.google.com/keflavich/SnowshoeingAboveI70"
    imagelinks[12]=""//http://picasaweb.google.com/keflavich/SnowshoeingAboveI70"
    imagelinks[9]=""//http://picasaweb.google.com/keflavich/SnowshoeingAboveI70"
    imagelinks[7]=""//http://www.nrao.edu/index.php/learn/gallery/imagecontest"
    imagelinks[11]=""//http://picasaweb.google.com/keflavich/GC/"
    //imagelinks[15]="http://picasaweb.google.com/keflavich/BerthoudPass12312008/"
    imagelinks[6]="http://www.flickr.com/photos/31267019@N06/sets/72157631612868259/"
    imagelinks[21]="https://lh3.googleusercontent.com/-tryyxY3TFvY/VXST971sXyI/AAAAAAAAVqc/joyLVU61PLM/w2236-h1258-no/20150605_101014.jpg"
    imagelinks[22]="https://www.eso.org/public/news/eso1711/"
    imagelinks[23]="https://www.aanda.org/highlights/2015-highlights/1132-the-orion-fingers-near-ir-adaptive-optics-imaging-of-an-explosive-protostellar-outflow-bally-et-al"

    var ry=Math.floor(Math.random()*myimages.length);
    while (myimages[ry] == undefined) {
        var ry=Math.floor(Math.random()*myimages.length);
    }
    document.write('<center><a href='+'"'+imagelinks[ry]+'"'+'><img src="'+myimages[ry]+'" height=241 border=0></a></center>')
}
