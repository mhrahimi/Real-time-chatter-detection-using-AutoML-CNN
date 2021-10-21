classdef CBandpassFilters
    properties
        SamplingPeriod
        Order
        StartBand
        NumberOfFilters
        
        Numerator
        Denominator
        E
        EDelayed
        EDelayedSingle
        ASingle
        BSingle
        ESingleTrans
        BandpassOutputs
    end
    methods
        function obj = CBandpassFilters(numOfBand, TPE, Ts)
            obj.SamplingPeriod = Ts;
            obj.Order = 4; % always 4 in this project
            obj.StartBand = 1; % always 1 in this project: ceil(startFreq / TPE)
            obj.NumberOfFilters = numOfBand;
            
            obj.Numerator = zeros(obj.NumberOfFilters, 2 * obj.Order + 1);
            obj.Denominator = zeros(obj.NumberOfFilters, 2 * obj.Order);
            obj.E = zeros(obj.NumberOfFilters, 2 * obj.Order + 1);
            obj.EDelayed = zeros(obj.NumberOfFilters, 2 * obj.Order);
            obj.EDelayedSingle = zeros(2 * obj.Order, 1);
            obj.ASingle = zeros(1, 2 * obj.Order);
            obj.BSingle = zeros(1, 2 * obj.Order + 1);
            obj.ESingleTrans = zeros(2 * obj.Order + 1, 1);
            obj.BandpassOutputs = zeros(obj.NumberOfFilters, 1);
            
            obj.CalculateCoefficients(TPE);
        end
        function CalculateCoefficients(obj, TPE)
            a1 = 0.7654; %this is constant parameter
            a2 = 1.8478; %this is constant parameter
            stopBand = zeros(2); %wc_c [Hz]
            wrappedStopBand = zeros(2); %wc_d [Hz]
            w0 = 0;
            dw = 0;
            Q = 0;
            
            for i = 1:obj.NumberOfFilters
                stopBand(1) = (1*TPE + i * TPE);
                stopBand(2) = stopBand(1) + TPE;
                
                wrappedStopBand(1) = 2.0 / obj.SamplingPeriod*tan(stopBand(1) * (2 * pi) * obj.SamplingPeriod / 2);  %[Hz]
                wrappedStopBand(2) = 2.0 / obj.SamplingPeriod*tan(stopBand(2) * (2 * pi) * obj.SamplingPeriod / 2);  %[Hz]
                
                w0 = power(wrappedStopBand(1) * wrappedStopBand(2), 0.5);  % [Hz]
                dw = wrappedStopBand(2) - wrappedStopBand(1);  % [Hz]
                Q = w0 / dw;  %unitless
                
                d8 = power(2 / obj.SamplingPeriod*Q / w0, 4);
                d7 = (a1 + a2)*power(2 / obj.SamplingPeriod*Q / w0, 3);
                d6 = power(2 / obj.SamplingPeriod*Q / w0, 2) * (a1*a2 + 2 * (2 * power(Q, 2) + 1));
                d5 = (2 / obj.SamplingPeriod) * (a1 + a2)*Q / w0*(3 * power(Q, 2) + 1);
                d4 = (6 * power(Q, 4) + (2 * a1*a2 + 4)* power(Q, 2) + 1);
                d3 = power(2 / obj.SamplingPeriod, -1) * (a1 + a2)*w0*Q*(1 + 3 * power(Q, 2));
                d2 = power(obj.SamplingPeriod / 2 * Q*w0, 2) * (4 * power(Q, 2) + 2 + a1*a2);
                d1 = (a1 + a2)*power(obj.SamplingPeriod / 2 * Q*w0, 3);
                d0 = power(Q*w0*obj.SamplingPeriod / 2, 4);
                
                dd0 = d0 - d1 + d2 - d3 + d4 - d5 + d6 - d7 + d8;
                dd1 = 8 * d0 - 6 * d1 + 4 * d2 - 2 * d3 + 2 * d5 - 4 * d6 + 6 * d7 - 8 * d8;
                dd2 = 28 * d0 - 14 * d1 + 4 * d2 + 2 * d3 - 4 * d4 + 2 * d5 + 4 * d6 - 14 * d7 + 28 * d8;
                dd3 = 56 * d0 - 14 * d1 - 4 * d2 + 6 * d3 - 6 * d5 + 4 * d6 + 14 * d7 - 56 * d8;
                dd4 = 70 * d0 - 10 * d2 + 6 * d4 - 10 * d6 + 70 * d8;
                dd5 = 56 * d0 + 14 * d1 - 4 * d2 - 6 * d3 + 6 * d5 + 4 * d6 - 14 * d7 - 56 * d8;
                dd6= 28 * d0 + 14 * d1 + 4 * d2 - 2 * d3 - 4 * d4 - 2 * d5 + 4 * d6 + 14 * d7 + 28 * d8;
                dd7 = 8 * d0 + 6 * d1 + 4 * d2 + 2 * d3 - 2 * d5 - 4 * d6 - 6 * d7 - 8 * d8;
                dd8 = d0 + d1 + d2 + d3 + d4 + d5 + d6 + d7 + d8;
                
                % Numerator
                obj.Numerator(i, 1) = 1.0 / dd8;
                obj.Numerator(i, 2) = 0;
                obj.Numerator(i, 3) = (-4.0) / dd8;
                obj.Numerator(i, 4) = 0 / dd8;
                obj.Numerator(i, 5) = 6.0 / dd8;
                obj.Numerator(i, 6) = 0 / dd8;
                obj.Numerator(i, 7) = (-4.0) / dd8;
                obj.Numerator(i, 8) = 0 / dd8;
                obj.Numerator(i, 9) = 1.0 / dd8;
                
                % Denominator
                obj.Denominator(i, 1) = dd7 / dd8;
                obj.Denominator(i, 2) = dd6 / dd8;
                obj.Denominator(i, 3) = dd5 / dd8;
                obj.Denominator(i, 4) = dd4 / dd8;
                obj.Denominator(i, 5) = dd3 / dd8;
                obj.Denominator(i, 6) = dd2 / dd8;
                obj.Denominator(i, 7) = dd1 / dd8;
                obj.Denominator(i, 8) = dd0 / dd8;
            end
        end
        function output = CalculateInput(measurement, estimation)
            output = measurement - estimation;
        end
        function output = UpdateBandpass(newTPE)
            output = obj.CalculateCoefficients(newTPE);
        end
        function RunBandpassFilters(obj, input)
            % ----- For loop to calculate A*(E_delayed)' of each filter and update 1st column of E signal
            for i = 1:obj.NumberOfFilters
                for j = 1:size(obj.EDelayed,2)
                    obj.EDelayedSingle(j) = obj.EDelayed(i, j); % Ed': [2n x 1]
                end
                for j = 1:size(obj.Denominator, 2)
                    obj.ASingle(j) = obj.Denominator(i, j); % Extract A of #(i+1) filter: [1 x 2n]
                end
                temp = (obj.ASingle * obj.EDelayedSingle);
                obj.E(i, 1) = input - temp(1);
            end
            
            % Update E signal of the remaining columns: copy from EDelayed signal
            for i = 1:obj.NumberOfFilters % # of filters
                for j = 1:size(obj.EDelayed, 2)
                    obj.E(i, j) = obj.EDelayed(i, j);
                end
            end
            
            % ---- for loop to calculate each filter's output---------
            for i = 1:obj.NumberOfFilters
                for j = 1:size(obj.E,2)
                    obj.ESingleTrans(j) = obj.E(i, j);
                end
                for j = 1:size(obj.Numerator, 2)
                    obj.BSingle(j) = obj.Numerator(i, j); % Extract A of #(i+1) filter: [1 x 2n]
                end
                temp = (obj.BSingle * obj.ESingleTrans);
                obj.BandpassOutputs = (temp(1)); % Output of #(i+1) filter: [1 x 1]
            end
            
            % Update delayed E
            for i = 1:obj.NumberOfFilters
                for j = 1:size(obj.EDelayed,2)-2
                    % 			index1 = i*EDelayed->Column + EDelayed->Column - 1 - j;
                    obj.EDelayed(i, end - j) = obj.EDelayed(i, end - j - 1);
                end
                obj.EDelayed(i, end) = obj.E(i, 1); % CHECK
            end
        end
    end
end