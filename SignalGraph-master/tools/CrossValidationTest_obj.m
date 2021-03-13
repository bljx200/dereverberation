% This function do a cross validation test of DNN.
%
% Author: Xiong Xiao, NTU
% Date Created: 10 Oct 2013
% Last Modified: 20 Jul 2015
%
function [cost,cost_pure,subcost,subacc] = CrossValidationTest_obj(layer, data, para, WorkerPool)
data = data.ShuffleData(para);

cost_cv = [];
if para.useGPU; 	cost_cv= gpuArray(cost_cv);        end
cost_cv_pure = cost_cv; subcost = cost_cv;    subacc = cost_cv;
randomOrder = 0;

nTestSample = [];
for blk_i = 1:data.nBlock
    pause(.1);
    if para.useGPU && para.displayGPUstatus==1
        gpuStatus = gpuDevice;
        fprintf('GPU has %2.2E free memory!\n', gpuStatus.FreeMemory);
    end
    
    if blk_i == 1 || ~para.IO.asyncFileRead
        minibatch = data.PrepareMinibatch(para.precision, para.NET.sequential, para.NET.batchSize, blk_i, randomOrder);
    else
        minibatch = fetchOutputs(MinibatchJob);     % collect the data from the work. It will block the main thread if the worker hasn't finished.
    end
    if ~isempty(WorkerPool) && para.IO.asyncFileRead && blk_i<data.nBlock   % call a worker to load the next block of data in background
        MinibatchJob = parfeval(WorkerPool,@data.PrepareMinibatch,1, para.precision, para.NET.sequential, para.NET.batchSize, blk_i+1, randomOrder);
    end
    
    nMiniBatch = size(minibatch,2);
    
    clear cost_func
    for batch_i=1:nMiniBatch
        batch_data = GetMinibatch(minibatch, batch_i, para.useGPU);
        for si=1:length(batch_data)
            batch_nFr(si) = size(batch_data{si},2);
        end
        
        % Evaluate the cost function and gradient on current batch
        nTestSample(end+1) = max(batch_nFr);
        [cost_func(batch_i)] = DNN_Cost10(layer, batch_data, para, 2);
        
        if mod(batch_i,para.displayInterval)==0 || (batch_i==nMiniBatch && para.displayInterval>batch_i)
            fprintf('CV cost at utterance %d/%d = %.4g / %.4g - %s\n', ...
                batch_i, nMiniBatch, mean([cost_func(max(1,batch_i-para.displayInterval+1) : batch_i).cost]), ...
                mean([cost_func(max(1,batch_i-para.displayInterval+1) : batch_i).cost_pure]), datestr(now));
        end
    end
    cost_cv = [cost_cv [cost_func(:).cost]];
    cost_cv_pure = [cost_cv_pure [cost_func(:).cost_pure]];
    subcost = [subcost [cost_func(:).subcost]];
    subacc = [subacc [cost_func(:).subacc]];
    clear minibatch;
    layer = clean_network_layer(layer);
end

subcost =  gather(subcost * nTestSample') / sum(nTestSample);
cost = gather(cost_cv(:)' * nTestSample') / sum(nTestSample);
cost_pure = gather(cost_cv_pure(:)' * nTestSample') / sum(nTestSample);
if isfield(cost_func(1),'subacc')
    subacc =  gather(subacc * nTestSample') / sum(nTestSample);
else
    subacc = [];
end

fprintf('    ----Development cost/cost_pure before training = %f / %f - %s\n', cost, cost_pure, datestr(now));
if length(subcost)>1
    fprintf('        ----subcosts = %f\n', subcost);
end
if length(subacc)>0
    fprintf('    ----(Sub)task accuracy = %2.2f%%\n', 100*subacc);
end

end
