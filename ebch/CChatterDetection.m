classdef CChatterDetection
    properties
        ChatterDetected
        PeriodicEnergy
        ChatterEnergy
        EnergyRatio
        EnergyThreshold
        EnergyRatioLimit
        
        PrevChatterDetected
        DetectionDelay
        DelayedPeriodicEnergy
    end
    methods
        function obj = CChatterDetection(ndMean, energyThreshold, energyRatioLimit)
            obj.ChatterDetected = 0;
            obj.PeriodicEnergy = 0;
            obj.ChatterEnergy = 0;
            obj.EnergyRatio = 0;
            obj.EnergyThreshold = energyThreshold;
            obj.EnergyRatioLimit = energyRatioLimit;
            
            obj.PrevChatterDetected = 0;
            obj.DetectionDelay = round((ndMean + 1) / 2); % num of delay of periodic energy
            obj.DelayedPeriodicEnergy = zeros(obj.DetectionDelay, 1); % initial condition is 0
        end
        function RunChatterDetection(obj)
            obj.EnergyRatio = obj.ChatterEnergy / ...
                (obj.ChatterEnergy + obj.DelayedPeriodicEnergy(1,1));
            
            if obj.PrevChatterDetected == 0 && obj.EnergyRatio > 0.5 % entry
                obj.ChatterDetected = 0;
            elseif obj.PrevChatterDetected == 1 && obj.EnergyRatio > 0.1 % chatter continues
                obj.ChatterDetected = 1;
            elseif obj.EnergyRatio > obj.EnergyRatioLimit && ...
                    obj.PeriodicEnergy > obj.EnergyThreshold % chatter just detected
                obj.ChatterDetected = 1;
            elseif obj.EnergyRatio < 0.1 % no chatter
                obj.ChatterDetected = 0;
            else
                obj.ChatterDetected = 0;
            end
            
            % Store chatter detection status using previous data
            obj.PrevChatterDetected = obj.ChatterDetected;
            
            % Update delayed periodic energy, DelayedPeriodicEnergy->Content[0] is the most delayed
            for i = 1:obj.DetectionDelay-1
                obj.DelayedPeriodicEnergy(i) = obj.DelayedPeriodicEnergy(i + 1);
            end
            obj.DelayedPeriodicEnergy(obj.DetectionDelay - 1) = obj.PeriodicEnergy;
        end
    end
end