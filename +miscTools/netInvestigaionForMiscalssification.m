clc
load("C:\Users\mhoss\Dropbox\Project MASc\Main - Small\DS\properties.mat")

treuC = netEval.test.classes.true;
predC = netEval.test.classes.pred;
ind = ml.labelingDiagnosis(treuC, predC, 'exit');
listFiles = imds.test.Files(ind);

[no, source, label, extention, subNo] = DStools.dsNameExtract(listFiles);

firstNum = mode(no);
properties.batchNo(firstNum)
