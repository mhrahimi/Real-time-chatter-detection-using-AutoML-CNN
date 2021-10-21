clear all
clc
% close all

%% vars
plottingIsOn = 1;
savingIsOn = 0;

wbar = waitbar(0,'Please wait...');
counter = 1;

load("C:\Users\mhoss\Desktop\Hossein\enetgyBased_mal\properties.mat");
path = "C:\Users\mhoss\Desktop\Hossein\enetgyBased_mal";
savingPath = "C:\Users\mhoss\Desktop\Hossein\enetgyBased_improved";
dataFolder = fullfile(path, 'test');
fftLength = 7000;
Fs = 5e4;
% fftRange = 5e3; % according to the paper  In most common milling operations, chatter occurs within 5 kHz
fftRange = 2e3;
% calStPoint = floor(fftLength/10);%100; % the point to start calculating EN ratio, before this point the ratio is 0
calStPoint = 1e4;

% improved
ieParam.windowSize = 25;
% ieParam.numSTD = 2;
%%
fdsKalman = fileDatastore(dataFolder,'ReadFcn', ...
    @(x) improvedEnergy.readFcn(x, 'kalmanOut'));
fdsPeriodic = fileDatastore(dataFolder,'ReadFcn', ...
    @(x) improvedEnergy.readFcn(x, 'priodicEn'));
numInstances = length(fdsKalman.Files);

fdsKalman.read; % delete it
% fdsPeriodic.read; % delete it
%
% fdsKalman.read; % delete it
% fdsPeriodic.read; % delete it
% if plottingIsOn
%     fig = util.paperFig;
% end
% for kk = 1:871 % skipping
%     counter = counter + 1;
%     fdsKalman.read;
%     fdsPeriodic.read;
% end

while(fdsKalman.hasdata)
    % reading
    [thisKalman, thisInfo] = fdsKalman.read;
    thisPeriodic = fdsPeriodic.read;
    [no, ~, label, ~] = ...
        DStools.dsNameExtract(convertCharsToStrings(thisInfo.Filename));
    label
    thisProp = properties(no, :);
    
    % physical calc
    spFreq = thisProp.S / 60;
    tpFreq = spFreq * thisProp.numFlutes; % omega_T (hz)
    
    harmonicsSP = [0:spFreq:fftRange];
    harmonicsTP = [tpFreq:tpFreq:fftRange];
    
    len = length(thisKalman);
    ratio = zeros(len,1);
    chatterEnergy = zeros(len,1);
    
    for i= calStPoint:len
        elig01 = [];
        
        st = max(1, i - fftLength);
        ed = i;
        [allAmp, allFreq] = tools.fftHandler(thisKalman(st:ed), Fs);
        freq = allFreq(allFreq <= fftRange);
        amp = allAmp(allFreq <= fftRange);
        
        % threshline
        thereshLine = improvedEnergy.threshold(amp, ieParam);
        
        eligibility = categorical("",{'Ineligible','Eligible'});
        eligibility((amp)<thereshLine) = categorical("Ineligible");
        eligibility(thereshLine <= (amp)) = categorical("Eligible");
        
        elig01((amp)< thereshLine) = nan;
        elig01(thereshLine<=(amp)) = 1;
        eligAmp = amp .* elig01'; % elig01 = [nan nan nan 1 1 1 1 1 1 nan nan ...
        
        [mx, mxInd, isRejected] = ...
            improvedEnergy.qualification(eligAmp, freq, harmonicsSP);
        acceptedPoints = mxInd(isRejected ~= 1);
        rejectedPoints = mxInd(isRejected == 1);
        
        chatterEnergy(i) = ...
            sum((freq(acceptedPoints) .* amp(acceptedPoints)).^2);
        if (chatterEnergy(i) + thisPeriodic(i)) ~= 0
            ratio(i) = chatterEnergy(i)/(chatterEnergy(i) + thisPeriodic(i));
        end
        
        %% plotting
        if plottingIsOn & 20000<i
            fSize = 12;
            
            subplot(2,1,1)
            fftHandle = plot(freq, (amp), 'black');
            title("Chatter Peaks Detection", 'FontSize', fSize+2)
            ylabel('Magnitude', 'FontSize', fSize);
            spHandle = xLineDraw(harmonicsSP, '--red');
            tpHandle = xLineDraw(harmonicsTP, '-.blue');
            
            hold on
            tholdline = plot(freq, thereshLine, 'green');
            set(gca,'xtick',[])
            
            hold off
            
            subplot(2,1,2);
            plot(freq, eligibility, 'green')
            spHandle = xLineDraw(harmonicsSP, '--red');
            tpHandle = xLineDraw(harmonicsTP, '-.blue');
            xlabel('Frequency (Hz)', 'FontSize', fSize);
            set(gca,'FontSize',fSize)
            
            subplot(2,1,1)
            hold on
            %             plot(freq,eligAmp, 'LineWidth', 1.3, 'Color', [0, 0.5, 0]);
            acceptedPointsHandle = pointsDraw...
                (freq(acceptedPoints), amp(acceptedPoints), 'cyan s');
            rejectedPointsHandle = pointsDraw...
                (freq(rejectedPoints), amp(rejectedPoints), 'red x');
            leg = legend([fftHandle, tholdline, spHandle(1) tpHandle(1), ...
                acceptedPointsHandle, rejectedPointsHandle], ...
                {'Fourier transform', 'Threshold Line', 'Tooth passing Harmonics', ...
                'Spindle Harmonics', 'Accepted Peaks', 'Rejected Peaks'});
            leg.NumColumns = 3;
            leg.FontSize = fSize;
            hold off
            drawnow
        end
    end
    % saving
    allFiles = fdsKalman.Files;
    thisFilePath = allFiles{counter};
    temp = strsplit(thisFilePath, filesep);
    thisFileName = fullfile(savingPath, temp{end-1}, temp{end});
    if savingIsOn
        save(thisFileName, 'chatterEnergy', 'ratio');
    end
    
    waitbar(counter/numInstances,wbar, ...
        ['Processed ', num2str(counter), ' out of ', num2str(numInstances)]);
    counter = counter + 1;
end


function lineSetHandle = xLineDraw(lineSet, options)
lineSetHandle = arrayfun(@(x) xline(x, options), lineSet);
end
function pointSetHandel = pointsDraw(x, y, options)
if ~isempty(x)
    point.x = x;
    point.y = y;
    
    pointSetHandel = arrayfun(@(point) plot(point.x, point.y, options), point);
else % empty plot
    pointSetHandel = plot(x,y);
end
end