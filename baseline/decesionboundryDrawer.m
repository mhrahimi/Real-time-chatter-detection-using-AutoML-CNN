clc
% clear all
% load("C:\Users\mhoss\Dropbox\Project MASc\Main\baseLine\newTrained\model.mat")
classifier = trainedModel.ClassificationTree;

% pness = .00005;
pness = .0001;

X1 = 0:.0002:.18;
X2 = -0.3:.005:.3;
% X = [X1', X2'];
labels  = categorical({'airuct', 'entrance', 'exit', 'chatter', 'stable'});

% x1range = min(X(:,1)):.01:max(X(:,1));
% x2range = min(X(:,2)):.01:max(X(:,2));
% [xx1, xx2] = meshgrid(x1range,x2range);
% [xx1, xx2] = meshgrid(X(:,1),X(:,2));
[xx1, xx2] = meshgrid(X1,X2);
XGrid = [xx1(:) xx2(:)];


predictedspecies = predict(classifier,XGrid);

gscatter(xx1(:), xx2(:), predictedspecies,'brymg');

title("Decision boundries", 'FontSize', 14)
xlabel("Standard Deviation (\sigma)", 'FontSize', 12)
ylabel("Skewness ($\tilde{\mu}_3$)", 'FontSize', 12, 'Interpreter', 'latex')
legend off, axis tight

% legend(labels,'Location',[0.35,0.01,0.35,0.05],'Orientation','Horizontal')