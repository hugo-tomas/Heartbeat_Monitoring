function diagnostic(pacient_ID,n_aquisitions)
load("AllPatients.mat","AllPatients");
% Arrhythmia Detection
bpm=AllPatients.("Patient"+pacient_ID).ECG_Info.("Aquisition"+n_aquisitions).ECG_Beats_minute;
if bpm<60
    arrhythmia="Bradycardia";
elseif bpm>100
    arrhythmia="Tachycardia";
    ventricular_rate=AllPatients.("Patient"+pacient_ID).ECG_Info.("Aquisition"+n_aquisitions).ECG_Ventricular_rate;
    if ventricular_rate>100
        arrhythmia="Ventricular Tachycardia";
    end
else 
    arrhythmia="Normal";
end
RR_interval=AllPatients.("Patient"+pacient_ID).ECG_Info.("Aquisition"+n_aquisitions).ECG_RR_Intervals;
if std(RR_interval)>0.120
    arrhythmia="Atrial Fibrillation";
end

% Ectopic Beat Detection
if sum(RR_interval<=0.8*mean(RR_interval))~=0
    ectopic="With "+sum(RR_interval<=0.8*mean(RR_interval))+" Premature Ventricular Contractions";
elseif sum((((RR_interval>0.8*mean(RR_interval))==1)+((RR_interval<0.9*mean(RR_interval))==1))==2)~=0
    ectopic="With "+sum((((RR_interval>0.8*mean(RR_interval))==1)+((RR_interval<0.9*mean(RR_interval))==1))==2)+" Premature Atrial Contractions";
else
    ectopic="Without Premature Ventricular or Atrial Contractions";
end
AllPatients.("Patient"+pacient_ID).ECG_Diagnostics.("Aquisition"+n_aquisitions).Arrhythmia=arrhythmia;
AllPatients.("Patient"+pacient_ID).ECG_Diagnostics.("Aquisition"+n_aquisitions).Ectopic_Beats=ectopic;
save("AllPatients.mat","AllPatients");
end
