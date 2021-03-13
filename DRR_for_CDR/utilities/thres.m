%--------------------------------------------------------------------------
% Apply lower and upper threshold for given vector or scalar
%--------------------------------------------------------------------------
% 08.06.11 - initial version (MJ)
%--------------------------------------------------------------------------
function x = thres(x,min,max)

% min and max can also be given by a 1x2 vector
% e.g. x = thres(x,minmax); with minmax = [-10,10]
if nargin < 3
    max = min(2);
    min = min(1);    
end;

x(x < min) = min;
x(x > max) = max;

%--------------------------------------------------------------------------