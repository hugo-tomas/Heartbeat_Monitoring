function SDNN = sdnn(Interval)
dif = 0;
for i=1:length(Interval)
    dif = dif + (Interval(i)-mean(Interval))^2;
end
SDNN = sqrt(dif/(length(Interval)-1));
end