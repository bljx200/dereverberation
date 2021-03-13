function rms = Cal_RMS(v) 
%
% Calculate root mean square of a vector
% Written by He Ba and Na Yang, University of Rochester, August 2013.
%
temp = 0;
for myi = 1:length(v)
    temp = temp + v(myi)^2;
end
rms = sqrt(temp/length(v));