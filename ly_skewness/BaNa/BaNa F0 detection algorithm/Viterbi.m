function [ minv, assn ] = Viterbi( c ) % c is n-1*m*m matrix, assn is n-length array
%
% Viterbi algorithm
% Written by Na Yang, University of Rochester, August 2013.
%
    n = size(c, 1) + 1;
    m = size(c, 2);

    pre = zeros(n, m); % prev stores the previous node
    val = zeros(n, m); % val stores the current cost
    
    val(1,:) = zeros(1, m);
    pre(1,:) = zeros(1, m);
    for i=2:n
        for j=1:m
            [val(i,j), pre(i,j)] = min(val(i-1,:)+c(i-1,:,j));
        end
    end
    [minv, id] = min(val(n,:)); % minv stores the min value (cost), id is the index for the tail node
    assn = zeros(1, n); % assignment
    assn(n) = id;
    for i = n-1:-1:1
        assn(i) = pre(i + 1, assn(i+1));
    end
end

