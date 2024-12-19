function RMSSD = rmssd(Interval)
RMSSD = 0;
for i = 1:length(Interval)-1
    RMSSD = RMSSD+(Interval(i+1)-Interval(i))^2;
end

RMSSD = sqrt(RMSSD/(length(Interval)-1));
end
