classdef TanhNode < GraphNode
    
    methods
        function obj = TanhNode(dimOut)
            obj = obj@GraphNode('Tanh',dimOut);
        end
        
        function obj = forward(obj,prev_layers)
            obj = obj.preprocessingForward(prev_layers);
            input = prev_layers{1}.a;
            obj.a = tanh(input);
            obj = forward@GraphNode(obj, prev_layers);
        end
        
        function obj = backward(obj,prev_layers, future_layers)
            if obj.skipGrad || obj.skipBP
                return;
            end
            
            future_grad = obj.GetFutureGrad(future_layers);
            output = obj.a;
            obj.grad{1} = (1-output.^2) .* future_grad;
            obj = backward@GraphNode(obj, prev_layers, future_layers);
        end
        
    end
    
end