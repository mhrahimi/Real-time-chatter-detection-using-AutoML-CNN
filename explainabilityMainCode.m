% https://www.mathworks.com/help/deeplearning/ref/imagelime.html
% https://www.mathworks.com/help/deeplearning/ug/gradcam-explains-why.html
% https://www.mathworks.com/help/deeplearning/ug/understand-network-predictions-using-occlusion.html
% https://www.mathworks.com/help/deeplearning/ug/understand-network-predictions-using-lime.html
% https://www.mathworks.com/help/deeplearning/ug/investigate-network-predictions-using-class-activation-mapping.html


clc

imPath = "C:\Users\mhoss\Desktop\Hossein\imds\training\stable\N_5_S_Mic_L_stable_g_23.jpg";

net = trainedNet;
img = imread(imPath);
[YPred,scores] = classify(net,img);

%% Lime
map = imageLIME(net,img,YPred);

figure
imshow(img,'InitialMagnification',150)
hold on
imagesc(map,'AlphaData',0.5)
colormap jet
colorbar

%% Lime n most important figures

[map,featureMap,featureImportance] = imageLIME(net,img,YPred);

numTopFeatures = 4;
[~,idx] = maxk(featureImportance,numTopFeatures);

mask = ismember(featureMap,idx);
maskedImg = uint16(mask).*img;

figure
imshow(maskedImg);

%% occlusion
figure;

map = occlusionSensitivity(net,img,YPred);
imshow(img,'InitialMagnification', 150)
hold on
imagesc(map,'AlphaData',0.5)
colormap jet
colorbar