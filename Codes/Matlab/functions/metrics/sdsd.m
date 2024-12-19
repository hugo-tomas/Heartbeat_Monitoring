function SDSD = sdsd(Interval)

RRdif = 0;
for i=1:length(Interval)-1
    RRdif = RRdif+abs(Interval(i)-Interval(i+1));
end
RRdif = RRdif/(length(Interval)-1);

dif = 0;
for i=1:length(Interval)-1
    dif = dif + (abs(Interval(i)-Interval(i+1))-RRdif)^2;
end

SDSD = sqrt(dif/(length(Interval)-1));
end