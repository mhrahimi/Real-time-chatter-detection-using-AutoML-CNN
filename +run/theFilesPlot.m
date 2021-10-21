chatterFile = "C:\Users\mhoss\Dropbox\Project MASc\Main - Small\+run\combined_chatter6567.mp3";
[chatter,Fs] = audioread(filename);
% util.fftHandler(y,Fs);

clc
prop.S = 12500;
prop.sampling = Fs;
prop.numFlutes = 4;
machining.plt(chatter,prop)

%%
stableFile = 