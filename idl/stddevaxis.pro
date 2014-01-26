; stddevaxis
; takes an n-dimensional array in variable 'x' and returns the
; standard deviation along the axis specified by 'dimension'
; should be equivalent to Python's std(x,axis=n)
; OPTIONS:
;   NAN allows you to specify that NAN values should be ignored
;   _extra parameters can be passed to stddev if a 1-d array is passed
;       or the usual stddev is desired
function stddevaxis,x,dimension=dimension,nan=nan,_extra=extra 
    if keyword_set(dimension) then begin
        dimsize = size(x,/dim)
        dimmean = total(x,dimension,nan=nan) / float(dimsize[dimension-1])
        dimvar = total( (x - dimmean#replicate(1,dimsize[dimension-1]))^2 ,dimension,nan=nan)$
            / float(dimsize[dimension-1])
        dimstd = sqrt(dimvar)
        return,dimstd
    endif else return,stddev(x,nan=nan,_extra=extra)
end

