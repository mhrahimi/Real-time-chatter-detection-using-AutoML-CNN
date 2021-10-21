classdef CKalmanFilter
    properties
        Phi
        
        N
        R
        SamplingPeriod
        Q
        q
        P
        
        qPrior
        PPrior
        K
        PeriodicAmp
    end
    methods
        function obj = CKalmanFilter(N_TPE, spindleSpeed, samplingPeriod, ...
                lamda, covariance)
            obj.Phi = zeros(2 * N_TPE, 1);
            
            for i = 1: N_TPE
                obj.Phi(2 * i - 1, 1) = cos(i *spindleSpeed*samplingPeriod);
                obj.Phi(2 * i , 1) = sin(i *spindleSpeed*samplingPeriod);
            end
            
            obj.N = N_TPE;
            obj.R = covariance;
            obj.SamplingPeriod = samplingPeriod;
            obj.Q = lamda * obj.R;
            obj.q = zeros(2 * obj.N, 1);
            obj.P = zeros(2 * obj.N, 2 * obj.N);
            
            for i = 1:size(obj.P, 1)
                P(i, i) = 10;
            end
            
            obj.qPrior = zeros(2 * obj.N, 1);
            obj.PPrior = zeros(2 * obj.N, 2 * obj.N);
            obj.K = zeros(2 * obj.N, 1);
            obj.PeriodicAmp = zeros(obj.N, 1);
        end
        function UpdateKalman(obj, newSpindleSpeed)
            for i = 0:obj.N
                obj.Phi(2 * i - 1, 1) = cos(i *newSpindleSpeed*samplingPeriod);
                obj.Phi(2 * i , 0) = sin(i *newSpindleSpeed*samplingPeriod);
            end
        end
        function spEst = RunKalman(obj, measurement)
            % 1: priori estimation of state q_k_priori = Phi*q_k-1
            for i = 1:obj.N
                index1 = 2 * i - 1;
                index2 = 2 * i ;
                obj.qPrior(index1) = obj.Phi(index1) * obj.q(index1) - ...
                    obj.Phi(index2) * obj.q(index2);
                obj.qPrior(index2) = obj.Phi(index2) * obj.q(index1) + ...
                    obj.Phi(index1) * obj.q(index2);
            end
            
            % 2: priori estimation error: P_k_prior = Phi*P_k-1*Phi' + Q
            %Phi*P_k - 1 * Phi'
            for i = 1:obj.N
                for j = 1:obj.N
                    obj.PPrior(2 * i - 1, 2 * j - 1) = obj.Phi(2 * j - 1,  1) * ...
                        (obj.P(2 * i - 1, 2 * j - 1) * obj.Phi(2 * i - 1,  1) - ...
                        obj.P(2 * i, 2 * j - 1) * obj.Phi(2 * i, 1)) - obj.Phi(2 * j, 1) * ...
                        (obj.P(2 * i - 1, 2 * j) * obj.Phi(2 * i - 1,  1) - obj.P(2 * i, 2 * j) * ...
                        obj.Phi(2 * i, 1));
                    
                    obj.PPrior(2 * i - 1, 2 * j) = obj.Phi(2 * j, 1) * (obj.P(2 * i - 1, 2 * j - 1) * ...
                        obj.Phi(2 * i - 1,  1) - obj.P(2 * i, 2 * j - 1) * obj.Phi(2 * i, 1)) + ...
                        obj.Phi(2 * j - 1,  1) * (obj.P(2 * i - 1, 2 * j) * obj.Phi(2 * i - 1,  1) - ...
                        obj.P(2 * i, 2 * j) * obj.Phi(2 * i, 1));
                    
                    obj.PPrior(2 * i, 2 * j - 1) = obj.Phi(2 * j - 1,  1) * (obj.P(2 * i - 1, 2 * j - 1) * ...
                        obj.Phi(2 * i , 1) + obj.P(2 * i, 2 * j - 1) * obj.Phi(2 * i - 1,  1)) - ...
                        obj.Phi(2 * j, 1) * (obj.P(2 * i - 1, 2 * j) * obj.Phi(2 * i , 1) + ...
                        obj.P(2 * i, 2 * j) * obj.Phi(2 * i - 1,  1));
                    
                    obj.PPrior(2 * i, 2 * j) = obj.Phi(2 * j, 1) * (obj.P(2 * i - 1, 2 * j - 1) * ...
                        obj.Phi(2 * i , 1) + obj.P(2 * i, 2 * j - 1) * obj.Phi(2 * i - 1,  1)) + ...
                        obj.Phi(2 * j - 1,  1) * (obj.P(2 * i - 1, 2 * j) * obj.Phi(2 * i , 1) + ...
                        obj.P(2 * i, 2 * j) * obj.Phi(2 * i - 1,  1));
                end
            end
            
            % Phi*P_K-1*Phi' + Q
            for i = 1:2 * obj.N
                obj.PPrior(i, i) = obj.PPrior(i, i) + obj.Q;
            end
            
            % 3. Kalman gain matrix: K_k = P_k_prior*H'*(H*P_k_prior*H'+R)^(-1)
            % Calculate inverse
            invSum = 0;
            for i = 1:obj.N
                for j = 1:obj.N
                    invSum = invSum + obj.PPrior(2 * i, 2 * j);
                end
            end
            inverse = 1.0 / (invSum + obj.R);
            
            for i = 1:2 * obj.N
                tempSum = 0;
                for j = 1:obj.N
                    tempSum = tempSum  + obj.PPrior(i, 2 * j);
                    obj.K(i) = inverse * tempSum;
                end
            end
            
            % 4. q_k = q_k_priori + K_k(s_k-H*q_k-1_priori)
            sMinusHqk = measurement;
            for i = 1:obj.N
                sMinusHqk = sMinusHqk - obj.qPrior(2 * i);
            end
            
            for i = 1:2*obj.N
                obj.q(i) = obj.qPrior(i) + obj.K(i) * sMinusHqk;
            end
            
            % 5. P_k = (I-K_k*H)P_k_priori
            for j = 1:2 * obj.N % each row second
                tempSum = 0;
                for k = 1:obj.N
                    tempSum = tempSum + obj.PPrior(2 * k, + j);
                end
                for i = 1:2 * obj.N % each column  first
                    obj.P(i, j) = -obj.K(i) * tempSum + obj.PPrior(i, j);
                end
            end
            
            % Estimation output Sp_est = H*q_k
            spEst = 0;
            for i = 1:obj.N
                spEst = spEst + obj.q(2 * i);
            end
            
            % periodic vibration amplitude = sqrt(q_k_2n-1^2 + q_k_2n^2)
            for i = 1:obj.N
                obj.PeriodicAmp(i) = power(power(obj.q(2 * i - 1), 2) + ...
                    power(obj.q(2 * i), 2), 0.5);
            end
        end
    end
end