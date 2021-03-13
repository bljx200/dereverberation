function f_smooth = Path_finder(fn, candidates_Cscore) % f_smooth: nframes*1, fn: nframes*nCandidates
%
% Use Viterbi algorithm to choose pitch decision from candidates.
% Files needed: Cal_transition_cost_score.m and Viterbi.m
% Written by Na Yang, University of Rochester, August 2013.
%
c = Cal_transition_cost_score(fn, candidates_Cscore);
[~, assn] = Viterbi(c);

% trace back to determine pitch decisions
f_smooth = zeros(size(fn,1),1);
for myn = 1:size(fn,1)
    f_smooth(myn) = fn(myn, assn(myn));
end


