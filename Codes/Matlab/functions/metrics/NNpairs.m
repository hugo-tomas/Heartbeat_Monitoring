function [NN50,pNN50] = NNpairs(Interval)
NN50 = 0;
for i = 1:length(Interval)-1
    if Interval(i+1)-Interval(i)>0.050
        NN50=NN50+1;
    end
end
pNN50 = 100*NN50/(length(Interval)-1);

end