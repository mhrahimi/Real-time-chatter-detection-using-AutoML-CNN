classdef CNonlinearEnergyOperator
    properties
        T
        D %lag matrix
        SDelayed
        phi_y_kD
        phi_y_k2D
        phi_s_k2D
        
        s_k
        s_kD
        s_k2D
        s_k3D
        s_k4D
        
        y_k
        y_kD
        y_k2D
        y_k3D
        
        Freq
        Amp
        PrevFreq
        PrevAmp
    end
    methods
        function obj = CNonlinearEnergyOperator(samplingPeriod, TPE, bandpassFilters)
            numFilters = bandpassFilters.NumberOfFilters;
            
            obj.T = samplingPeriod;
            obj.D = zeros(1, bandpassFilters.NumberOfFilters);
            obj.CalculateLag(TPE, bandpassFilters);
            
%             obj.SDelayed = zeros(numFilters, 4 * floor(max(max(obj.D))));
            obj.SDelayed = zeros(numFilters, 4 * max(floor(max(max(obj.D))), 1));
            obj.phi_y_kD = zeros(numFilters, 1);
            obj.phi_y_k2D = zeros(numFilters, 1);
            obj.phi_s_k2D = zeros(numFilters, 1);
            
            obj.s_k = zeros(numFilters, 1);
            obj.s_kD = zeros(numFilters, 1);
            obj.s_k2D = zeros(numFilters, 1);
            obj.s_k3D = zeros(numFilters, 1);
            obj.s_k4D = zeros(numFilters, 1);
            
            obj.y_k = zeros(numFilters, 1);
            obj.y_kD = zeros(numFilters, 1);
            obj.y_k2D = zeros(numFilters, 1);
            obj.y_k3D = zeros(numFilters, 1);
            
            obj.Freq = zeros(numFilters, 1);
            obj.Amp = zeros(numFilters, 1);
            obj.PrevFreq = zeros(numFilters, 1);
            obj.PrevAmp = zeros(numFilters, 1);
        end
        function CalculateLag(obj, TPE, bandpassFilters)
            for i = 1:bandpassFilters.NumberOfFilters
                obj.D(i) = round((1 / obj.T) / ...
                    (4 * (bandpassFilters.StartBand + i)*TPE + TPE / 2) + 0.5);
            end
        end
        function RunNEO(obj, input)
            % Update input from bandpass filter bank
            for i = 1:size(input, 1)
                delay = floor(obj.D(i));
                index = (i + 1)*size(obj.SDelayed,2);
                obj.s_k(i) = input(i);
                obj.s_kD(i) = obj.SDelayed(i, end - delay);
                obj.s_k2D(i) = obj.SDelayed(i, end - 2 * delay);
                obj.s_k3D(i) = obj.SDelayed(i, end - 3 * delay);
                obj.s_k4D(i) = obj.SDelayed(i, end - 4 * delay);
            end
            
            % Calculate y_k, y_k-D, y_k-2D and y_k-3D
            obj.y_k = obj.s_k - obj.s_kD;
            obj.y_kD = obj.s_kD - obj.s_k2D;
            obj.y_k2D = obj.s_k2D - obj.s_k3D;
            obj.y_k3D = obj.s_k3D - obj.s_k4D;
            
            % Calculate Phi[y_(k-D)], Phi[y_(k-2D)], Phi[s_(k-2D)]
            for i = 1:size(input, 1)
                obj.phi_y_kD(i) = power(obj.y_kD(i), 2) - obj.y_k2D(i) * obj.y_k(i);
                obj.phi_y_k2D(i) = power(obj.y_k2D(i), 2) - obj.y_k3D(i) * obj.y_kD(i);
                obj.phi_s_k2D(i) = power(obj.s_k2D(i), 2) - obj.s_k3D(i) * obj.s_kD(i);
            end
            
            % Calculate frequency and amplitude
            for i = 1:size(input, 1)
                phi_xd = obj.phi_y_k2D(i) + obj.phi_y_kD(i);
                if (obj.phi_s_k2D(i) > 0 && phi_xd > 0 && phi_xd < 8 * obj.phi_s_k2D(i))
                    obj.Freq(i) = acos(1 - phi_xd / (4 * obj.phi_s_k2D(i))) ...
                        / T / obj.D(i); % in rad/s
                    obj.Amp(i) = power(obj.phi_s_k2D(i) / (1 - power(1 - phi_xd / ...
                        (4 * obj.phi_s_k2D(i)), 2)), 0.5);
                else
                    obj.Freq(i) = obj.PrevFreq(i); % in rad/s
                    obj.Amp(i) = obj.PrevAmp(i);
                end
            end
            
            % Update delayed input from bandpass filter
            for i = 1:size(input, 1)
                for j = 1:size(obj.SDelayed, 2)-1
                    obj.SDelayed(i, j) = obj.SDelayed(i, j+1);
                end
                obj.SDelayed(i + 1, j - 1)= input(i);
            end
            
            % Update previous frequency and amplitude
            for i = 1:size(input, 1)
                obj.PrevFreq(i) = obj.Freq(i);
                obj.PrevAmp(i) = obj.Amp(i);
            end
        end
    end
end