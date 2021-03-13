function xskew = kurt( xr, lseg,theta )
w=hamming(lseg);%È¡Ò»¶Î
sw=sum(w);
xr2=conv(xr.^2, w, 'same')/sw;%E[(X-mu)^4]
xr3=conv(xr.^3, w, 'same')/sw;
xr4=conv(xr.^4, w, 'same')/sw;
xskew=xr3./(xr2.^(3/2)+theta);
end

