!rm list_fit
!ls *.FIT > list_fit
!sed -e 's/\.FIT/\.fits/g' -e "s:^:$PWD/:" $PWD/list_fit > $PWD/list_fits
imdel @list_fits
rfits @list_fit 0 @list_fits datatype=u
