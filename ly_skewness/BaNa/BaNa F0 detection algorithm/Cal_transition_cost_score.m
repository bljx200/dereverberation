function transition_cost = Cal_transition_cost_score(fn, candidates_Cscore) % fn is an n*m matrix, fn: m pitch candidates for n frames
%
% Calculate the cost between candidates of neigboring frames, based on
% pitch difference and candidates' confidence score.
% Written by Na Yang, University of Rochester, August 2013.
%
n = size(fn,1); % number of frames
m = size(fn,2); % number of candidates per frame
transition_cost = zeros(n-1,m,m);

w = 0.4; % weight w is set to balance the impact of pitch difference and confidence score on cost

for myn = 1:n-1
    for myi = 1:m
        for myj = 1:m
            if (fn(myn+1,myj)==0) || (fn(myn,myi) == 0)
                transition_cost(myn,myi,myj) =99999;
            else
               transition_cost(myn,myi,myj) = abs(log2(fn(myn,myi)/fn(myn+1,myj))) + w/candidates_Cscore(myn,myi);
            end
        end
    end
end
