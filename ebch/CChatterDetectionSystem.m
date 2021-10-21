classdef CChatterDetectionSystem
    properties
        ChatterEnergyThreshold
        SpindleSpeed
        N
        NumberOfFlute
        SamplingPeriod
        Lamda
        R
        EnergyThreshold
        EnergyRatioLimit
        IntegrationFactor
        
        ThresholdEng
        
        KalmanFilter
        BandpassFilters
        NEO
        
        ChatterMeanFilter
        PeriodicMeanFilter
        FreqMeanFilter
        AmpMeanFilter
        
        ChatterDetection
        
        ChatterFreq
        PrevChatterFreq
        ChatterFreqVariation
        ChatterEnergy
        ChatterOutput
    end
    methods
        function obj = CChatterDetectionSystem(N_, numOfFlute, spindleSpeed,...
                samplingPeriod, lamda, R_, numOfBand, energyThreshold, energyRatioLimit, ...
                integrationFactor, chatterEnergyThreshold, ndMean, delay)
            obj.ChatterEnergyThreshold = chatterEnergyThreshold;
            obj.SpindleSpeed = spindleSpeed;
            obj.N = N_;
            obj.NumberOfFlute = numOfFlute;
            obj.SamplingPeriod = samplingPeriod;
            obj.Lamda = lamda;
            obj.R = R_;
            obj.EnergyThreshold = energyThreshold;
            obj.EnergyRatioLimit = energyRatioLimit;
            obj.IntegrationFactor = integrationFactor;
            obj.ThresholdEng = 0;
            
            obj.KalmanFilter = CKalmanFilter(N_, spindleSpeed, samplingPeriod, lamda, R_);
            obj.BandpassFilters = CBandpassFilters(numOfBand, numOfFlute*spindleSpeed/(2 * pi), samplingPeriod);
            obj.NEO = CNonlinearEnergyOperator(samplingPeriod, numOfFlute*spindleSpeed / (2 * pi), obj.BandpassFilters);
            
            obj.ChatterMeanFilter = CMeanFilter(1, delay);
            obj.PeriodicMeanFilter = CMeanFilter(1, delay);
            obj.FreqMeanFilter = CMeanFilter(obj.BandpassFilters.NumberOfFilters, ndMean);
            obj.AmpMeanFilter = CMeanFilter(obj.BandpassFilters.NumberOfFilters, ndMean);
            
            obj.ChatterDetection = CChatterDetection(ndMean, energyThreshold, energyRatioLimit);
            
            obj.ChatterFreq = zeros(obj.BandpassFilters.NumberOfFilters, 1);
            obj.PrevChatterFreq = zeros(obj.BandpassFilters.NumberOfFilters, 1);
            obj.ChatterFreqVariation = zeros(obj.BandpassFilters.NumberOfFilters, 1);
            obj.ChatterEnergy =  zeros(obj.BandpassFilters.NumberOfFilters, 1);
            %             obj.ChatterOutput = new SChatterOutput[BandpassFilters.NumberOfFilters];
        end
        function Run(obj, measurement)
            % Run Kalman filter, bandpass filter and NEO
            estimation = obj.KalmanFilter.RunKalman(measurement);
            obj.BandpassFilters.RunBandpassFilters(measurement-estimation);
            obj.NEO.RunNEO(obj.BandpassFilters.BandpassOutputs);
            
            % Mean filter the frequency and amplitude output from NEO
            obj.FreqMeanFilter.RunMeanFilter(obj.NEO.Freq);
            obj.AmpMeanFilter.RunMeanFilter(obj.NEO.Amp);
            
            % Calculate periodic energy and chatter energy and mean filter the output
            obj.ChatterDetection.ChatterEnergy = obj.ChatterMeanFilter.RunMeanFilter...
                (obj.CalculateChatterEnergy(obj.FreqMeanFilter.MOutput, obj.AmpMeanFilter.MOutput));
            obj.ChatterDetection.PeriodicEnergy = obj.PeriodicMeanFilter.RunMeanFilter...
                (obj.CalculatePeriodicEnergy(obj.KalmanFilter.PeriodicAmp));
            
            obj.ChatterDetection.RunChatterDetection();
        end
        function totalChatterEnergy = CalculateChatterEnergy(obj, freqIn, ampIn)
            totalChatterEnergy = 0.0;
            for i = 1:size(freqIn, 1)
                currentFreq = freqIn(i);
                currentAmp = ampIn(i);
                
                if currentFreq ~= 0 
                    obj.ChatterEnergy(i) = chatterEng;
                    totalChatterEnergy = totalChatterEnergy + chatterEng;
                    
                    % if frequency is 0, outputs are initial conditions: 0. Do nothing.
                else
                    obj.ChatterEnergy(i) = 0;
                end
            end
            
            obj.ThresholdEng = totalChatterEnergy * obj.ChatterEnergyThreshold;
        end
        function periodicEnergy = CalculatePeriodicEnergy(obj, amplitude)
            periodicEnergy = 0;
            
            for i=1:size(amplitude, 1)
                frequency = i * obj.SpindleSpeed;
                
                % if frequency is 0, outputs are initial conditions: 0. Do nothing.
                if frequency ~= 0
                    periodicEnergy = periodicEnergy + power(amplitude(i), 2)*power(frequency, 2 * obj.IntegrationFactor);
                end
            end
        end
%         function 
        
    end
end