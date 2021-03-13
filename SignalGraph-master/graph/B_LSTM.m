% Implement the back propagation of an LSTM layer.
% Author: Xiong Xiao, Temasek Labs, NTU, Singapore.
% Last modified: 13 Oct 2015
%
function [grad, grad_W, grad_b] = B_LSTM(input_layer, LSTM_layer, future_layers)
input = input_layer.a;
W = LSTM_layer.W;
if strcmpi(class(input), 'gpuArray'); useGPU=1; else useGPU = 0; end
precision = class(gather(input(1)));

future_grad = GetFutureGrad(future_layers, LSTM_layer);

[dim, nFr, nSeg] = size(input);
if nSeg>1
    [mask, variableLength] = getValidFrameMask(input_layer);
    if variableLength;
        future_grad = PadShortTrajectory(future_grad, mask, 0);
        input = PadShortTrajectory(input, mask, 0);
    end
end

input = permute(input, [1 3 2]);

nCell = LSTM_layer.dim(1);  % number of LSTM cells in the layer

useHidden = single(1);
usePastState = single(1);
usePastStateAsFeature = LSTM_layer.usePastState;

grad_ht_cost = future_grad;
grad_ht_cost = permute(grad_ht_cost,[1 3 2]);

ft = LSTM_layer.ft;
it = LSTM_layer.it;
ot = LSTM_layer.ot;
Ct_raw = LSTM_layer.Ct_raw;
Ct = LSTM_layer.Ct;
ht = LSTM_layer.a;
ht = permute(ht, [1 3 2]);
Ct0 = LSTM_layer.Ct0;
ht0 = LSTM_layer.ht0;

% allocate memory for the gradients of gates and states
if useGPU == 0
    if LSTM_layer.passGradBack; grad_xt = zeros(dim, nSeg, nFr, precision); end
    grad_Ct_future_curr = zeros(nCell, nSeg, precision);     % cell states
    grad_ht_future_curr = zeros(nCell, nSeg, precision);     % hidde layer output, i.e. the output of the LSTM layer
    grad_zt = zeros(nCell*4,nSeg, nFr, precision);
else
    if LSTM_layer.passGradBack; grad_xt = gpuArray.zeros(dim, nSeg, nFr, precision); end
    grad_Ct_future_curr = gpuArray.zeros(nCell, nSeg, precision);     % cell states
    grad_ht_future_curr = gpuArray.zeros(nCell, nSeg, precision);     % hidde layer output, i.e. the output of the LSTM layer
    grad_zt = gpuArray.zeros(nCell*4,nSeg, nFr, precision);
end
    
Ct_raw_prod = 1 - Ct_raw.*Ct_raw;
tanh_Ct_all = tanh(Ct);
termFromTanhCtAndOt = (1-tanh_Ct_all.*tanh_Ct_all) .* ot;
Gates = [ft; it; ot];
GatesTerm =  Gates .* (1-Gates);
W2 = W';
W2 = [W2(:,1:nCell) W2(:,2*nCell+1:end) W2(:,nCell+1:2*nCell)];
Ct_CtRaw_tanCtAll = [Ct(:,:,1:end-1); Ct_raw(:,:,2:end); tanh_Ct_all(:,:,2:end)];

% we only need the current value of the grad of the gates, we don't need to
% store them

for t = nFr:-1:1
    % compute the gradient of ht and Ct that requires gradients from
    % future. At frame nFr, the future gradients are initialized to 0.
    if useHidden
        grad_ht_curr = grad_ht_future_curr + grad_ht_cost(:,:,t);
    else
        grad_ht_curr = grad_ht_cost(:,:,t);
    end
    grad_Ct_curr = grad_Ct_future_curr + grad_ht_curr .* termFromTanhCtAndOt(:,:,t);
    
    % compute the gradient of gates and candidate states
    if usePastState
        if t==1
        else
            grad_Ct_future_curr = grad_Ct_curr .* ft(:,:,t);
        end
    end
    grad_Ct_raw_curr = grad_Ct_curr .* it(:,:,t);

    if t==1
        grad_gates = [grad_Ct_curr; grad_Ct_curr; grad_ht_curr] .* [Ct0; Ct_raw(:,:,t); tanh_Ct_all(:,:,t)];
    else
        grad_gates = [grad_Ct_curr; grad_Ct_curr; grad_ht_curr] .* Ct_CtRaw_tanCtAll(:,:,t-1); %[Ct(:,:,t-1); Ct_raw(:,:,t); tanh_Ct_all(:,:,t)];        
    end
    
    % compute the gradient of the gates before the activation function.

    grad_zCt_raw = grad_Ct_raw_curr .* Ct_raw_prod(:,:,t);    % batch processing on Ct_raw
    grad_zgates = grad_gates .* GatesTerm(:,:,t);   % apply operation independent of loop in batch
    grad_zt_curr = [grad_zgates; grad_zCt_raw];     % avoid complicated memory operation
    grad_zt(:,:,t) = grad_zt_curr;
    
    % compute the gradient of the W, b, and past hidden, past state, and x
    grad_yt = W2 * grad_zt_curr;    % use re-organized W
    
    if LSTM_layer.passGradBack
        if  usePastStateAsFeature
            grad_xt(:,:,t) = grad_yt(nCell*2+1:end,:);
        else
            grad_xt(:,:,t) = grad_yt(nCell+1:end,:);    % if the grad w.r.t. input data is not necessary (i.e. no trainable parameters before this LSTM layer, we don't need to compute grad_xt
        end
    end
    if t==1
    else
        if usePastStateAsFeature
            grad_Ct_future_curr = grad_Ct_future_curr + grad_yt(1:nCell,:);
            grad_ht_future_curr = grad_yt(nCell+1:nCell*2,:);
        else
            grad_ht_future_curr = grad_yt(1:nCell,:);
        end
    end
end
grad_zt = [grad_zt(1:nCell,:,:); grad_zt(end-nCell+1:end,:,:); grad_zt(nCell+1:end-nCell,:,:)];   % re-organize grad_zt

if usePastStateAsFeature
    tmpMat = [Ct(:,:,1:nFr-1); ht(:,:,1:nFr-1)*useHidden; input(:,:,2:nFr)];
else
    tmpMat = [ht(:,:,1:nFr-1)*useHidden; input(:,:,2:nFr)];
end
tmpMat = reshape(tmpMat, size(tmpMat,1), nSeg*(nFr-1));
tmpMat2 = reshape(grad_zt(:,:,2:nFr), nCell*4, nSeg*(nFr-1));
grad_W = tmpMat2 * tmpMat';
if usePastStateAsFeature
    grad_W = grad_W + grad_zt(:,:,1) * [Ct0; ht0*useHidden; input(:,:,1)]';
else
    grad_W = grad_W + grad_zt(:,:,1) * [ht0*useHidden; input(:,:,1)]';
end

grad_b = sum(sum(grad_zt,3),2);
if LSTM_layer.passGradBack
    grad = permute(grad_xt,[1 3 2]); 
else
    grad = [];
end
end
