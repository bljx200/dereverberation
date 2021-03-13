%snr
function snr=snrly(S,withN)
pS=norm(S).^2;

pN=norm(S-withN).^2;

snr=10*log(pS/pN);
end