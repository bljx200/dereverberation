function xkurt = kurt( xr, lseg,theta )
w=hamming(lseg);
sw=sum(w);
xr2=conv(xr.^2, w, 'same')/sw;%E[(X-mu)^4]
xr4=conv(xr.^4, w, 'same')/sw;
xkurt=xr4./(xr2.^2+theta);
end

