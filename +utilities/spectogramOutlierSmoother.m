function specto = spectogramOutlierSmoother(specto)
avg = mean(specto');
totalAvg = mean(avg);
st = std(avg);
i = 1;
while totalAvg+4*st <= avg(i) 
    i = i+1;
end
replacment = mean(specto(3:5,:))';
for j = i-1:-1:1
    specto(j,:)=  replacment;
end
end