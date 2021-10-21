% close all

width = 2;
len = 15;
YLIM = 7e3;

cropping = 1;
croppedSTFT = STFTMatrix(cropping:end-cropping+1,:);

filt = [-1*ones(width,len);
    2*ones(width,len);
    -1*ones(width,len)];

convImg = conv2(croppedSTFT, filt, 'valid');

subplot(1,2,1)
imagesc(t,f,croppedSTFT)
% ylim([0 YLIM])
ax = gca;
ax.YDir = 'normal';
xlabel('Time [s]', 'FontSize', 12);
ylabel('Frequency [Hz]', 'FontSize', 12);

subplot(1,2,2)
imagesc(t,f,convImg)
set(gca,'ytick',[])
% ylim([0 YLIM])
ax = gca;
ax.YDir = 'normal';
xlabel('Time [s]', 'FontSize', 12);

%%
toothpassing = 160;
numTeeth = 4;

offset = 0;
SpindleFreq = [0:toothpassing*numTeeth:2.5e4]-offset;
SpindleFreq = [-flip(SpindleFreq(2:end))+offset,SpindleFreq];

toothePassingFreq = [0:toothpassing:2.5e4]-offset;
toothePassingFreq = [-flip(toothePassingFreq(2:end))+offset,toothePassingFreq];

subplot(1,2,1)
for i = 1:length(SpindleFreq)
    yline(SpindleFreq(i), '--red');
end
hold on

for i = 1:length(toothePassingFreq)
    %     if ~mod(i,numTeeth)
    yline(toothePassingFreq(i), '-.blue');
    %     end
end
hold off


subplot(1,2,2)
for i = 1:length(SpindleFreq)
    spinFreqHandle(i) = yline(SpindleFreq(i), '--red');
end
hold on

for i = 1:length(toothePassingFreq)
    %     if ~mod(i,numTeeth)
    TPFreqHandle(i) = yline(toothePassingFreq(i), '-.blue');
    %     end
end
hold off

legend([spinFreqHandle(1)], ...
    {'Spindle Harmonic'}, 'FontSize', 12);
colorbar

%%
figure
subplot(1,2,1)
imagesc(t,f/1e4,convImg)
ax = gca;
ax.FontSize = 11; 
caxis([-2000 2000])
xlabel('Time [s]', 'FontSize', 13);
ylabel('Frequency [kHz]', 'FontSize', 13);
title('Convolved STFT', 'FontSize', 14)

subplot(1,2,2)
afterRelu = convImg;
afterRelu(afterRelu<0) = 0;
% clmap= colormap;
% clmap(end/2, :) = [0 0 0];
% clmap(end/2-1, :) = [0 0 0];
% clmap(end/2+1, :) = [0 0 0];
% colormap(clmap);
imagesc(t,f/1e4,afterRelu)
ax = gca;
ax.FontSize = 11; 
colorbar
caxis([-2000 2000])
xlabel('Time [s]', 'FontSize', 13);
title('Convolved STFT after applying ReLU', 'FontSize', 14)


%%
afterReludla = dlarray(afterRelu,'SSCB');
afterMaxPool = maxpool(afterReludla, 3, 'Stride', 2);

subplot(1,2,1)
afterRelu = convImg;
afterRelu(afterRelu<0) = 0;
imagesc(t,f/1e4,afterRelu)
ax = gca;
ax.FontSize = 11; 
caxis([-2000 2000])
xlabel('Time [s]', 'FontSize', 13);
ylabel('Frequecy [kHz]', 'FontSize', 13);
title('Convolved STFT after applying ReLU', 'FontSize', 14)

subplot(1,2,2)
afterRelu = convImg;
afterRelu(afterRelu<0) = 0;
imagesc(t,f/1e4,extractdata(afterMaxPool))
ax = gca;
ax.FontSize = 11; 
colorbar
caxis([-2000 2000])
xlabel('Time [s]', 'FontSize', 13);
title('After applying Max-pooling', 'FontSize', 14)


function tpdraw()
for i = 1:length(SpindleFreq)
    yline(SpindleFreq(i)/1e4, '--red');
end
hold on

for i = 1:length(toothePassingFreq)
    %     if ~mod(i,numTeeth)
    yline(toothePassingFreq(i)/1e4, '-.blue');
    %     end
end
end