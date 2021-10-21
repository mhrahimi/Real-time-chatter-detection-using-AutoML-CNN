classdef CMeanFilter
    properties
        Counter
        NumOfInput
        NumDelay
        Output
        MOutput
        MPrevOutput
        PrevOutput
    end
    methods
        function obj = CMeanFilter(numOfInput, numOfDelay)
            obj.Counter = 0;
            obj.NumOfInput = numOfInput;
            obj.NumDelay = 1.0 * numOfDelay;
            obj.Output = 0;
            obj.MOutput = zeros(numOfInput, 1); %Initial condition is 0
            obj.MPrevOutput = zeros(numOfInput, 1); %Initial condition is 0
            obj.PrevOutput = 0;
        end
        function MOutputLocal = RunMeanFilter(obj, input)
            for i = 1:obj.NumOfInput
                if obj.Counter < obj.NumDelay
                    % if counter = 0, output is 0
                    if obj.Counter ~= 0
                        obj.MOutput(i) = (obj.Counter - 1) / ...
                            obj.Counter*obj.MPrevOutput(i) + 1 / obj.Counter*input(i);
                    end
                else
                    obj.MOutput(i) = (obj.NumDelay - 1) / ...
                        obj.NumDelay*obj.MPrevOutput(i) + 1 / obj.NumDelay*input(i);
                end
            end
            
            % Update previous output
            for i = 1:obj.NumOfInput
                obj.MPrevOutput(i) = obj.MOutput(i);
            end
            
            % Increase counter
            obj.Counter = obj.Counter + 1;
            MOutputLocal = obj.MOutput;
        end
%         function Output = RunMeanFilter(input)
%             if obj.Counter < obj.NumDelay
%                 if obj.Counter ~= 0
%                     Output = (obj.Counter - 1) / obj.Counter * obj.PrevOutput + ...
%                         1 / obj.Counter*input;
%                 end
%             else
%                 Output = (obj.NumDelay - 1) / obj.NumDelay*obj.PrevOutput + ...
%                     1 / obj.NumDelay*input;
%             end
%             
%             % Update previous output
%             obj.PrevOutput = Output;
%             
%             % Increase counter
%             obj.Counter = obj.Counter + 1;
%         end
    end
end