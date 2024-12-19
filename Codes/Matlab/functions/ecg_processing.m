function [ecg_processed,ecg_Bandpass,ecg_diff,ecg_energy,ecg_movAvg,Peaks,beats_min,all_Beats,avg_Beat,beat_points,RR_interval,metrics]=ecg_processing(time,ecg,samplingRate,mov_avgSeconds,cutoff_preprocessed,bandpass,time_window)
    
    % Frequency Constants 
    fs = samplingRate; % Sampling frequency
    fmax = 0.5*fs; % Maximum frequency of signal

    % BaseLine Removal
    points_avg=round(mov_avgSeconds/(1/samplingRate));
    b=(1/points_avg)*ones(1,points_avg);
    ecg_avg = filtfilt(b,1, ecg);
    ecg_processed=ecg-ecg_avg;
    
    % Lowpass Filter - Noise reduction
    fc = cutoff_preprocessed; % Cut frequency
    wc = fc/fmax;
    order = 8;
    [b,a] = butter(order,wc,'low');
    ecg_processed = filtfilt(b,a,ecg_processed); % Remove the delay effect
    
    if length(bandpass)>=2
        % Lowpass
        fc = bandpass(2);
        wc = fc/fmax;
        order = 8;
        [b,a] = butter(order,wc);
        ecg_lowBandpass = filtfilt(b,a,ecg_processed);

        % Highpass
        fc = bandpass(1);
        wc = fc/fmax;
        [b,a] = butter(order,wc,'high');
        ecg_Bandpass = filtfilt(b,a,ecg_lowBandpass);
    end

 % With this portion of code, we try develop a peak detection algorithm
 % with Pan&Tompkins methodologie

    % Differentiation and potentiation
    ecg_diff = diff(ecg_Bandpass);
    ecg_energy = ecg_diff.^2;

    % Moving Average
    N = round(fs * time_window);
    b = (1/N)*ones(1, N);
    ecg_movAvg = filtfilt(b, 1, ecg_energy);
    
    % Peaks detection
    threshold=0.5*max (ecg_movAvg);
    c1 = ecg_movAvg>threshold;
    c2 = max(diff(c1),0);
    R_peaks = [];
    ind = find(c2 == 1);
    for i = 1:numel(ind)-1
        peak_max = find(ecg_processed == max(ecg_processed(ind(i):ind(i+1))));
        R_peaks = [R_peaks peak_max];
    end

%     [~,Q_peaks_energy] = findpeaks(ecg_energy,'MinPeakHeight',0.3*max(ecg_energy));
%     [~,R_peaks_energy] = findpeaks(ecg_energy,'MinPeakHeight',0.7*max(ecg_energy));
%     [~,S_peaks_energy] = findpeaks(ecg_energy,'MinPeakHeight',0.05*max(ecg_energy));
%     S_peaks_energy=setdiff(S_peaks_energy,Q_peaks_energy);
%     Q_peaks_energy=setdiff(Q_peaks_energy,R_peaks_energy);

    [~,Q_peaks] = findpeaks(-ecg_processed,'MinPeakHeight',0.7*max(-ecg_processed));
    [~,S_peaks] = findpeaks(-ecg_processed,'MinPeakHeight',0.4*max(-ecg_processed));
    [~,P_peaks] = findpeaks(ecg_processed,'MinPeakHeight',0.05*max(ecg_processed));
    [~,T_peaks] = findpeaks(ecg_processed,'MinPeakHeight',0.08*max(ecg_processed));    
    Peaks.P_peaks=setdiff(P_peaks,T_peaks);
    Peaks.T_peaks=setdiff(T_peaks,R_peaks);
    Peaks.S_peaks=setdiff(S_peaks,Q_peaks);
    Peaks.Q_peaks=Q_peaks;
    Peaks.R_peaks=R_peaks;

    % BPM
    num_beats = size(R_peaks,2);
    beats_min = (num_beats*60)/(time(end)-time(1));    
    
    % NN intervals
    RR_interval=time(R_peaks(2:end))-time(R_peaks(1:end-1));

    % Average Beat
    avg_beat = mean(RR_interval);
    beat_points = round(avg_beat/(1/fs))-1;
    auricular = round(1/3*beat_points);
    ventricular = round(2/3*beat_points);
    
    new_R_peaks=R_peaks;
    if R_peaks(end)+ventricular > numel(ecg_processed)
        new_R_peaks=new_R_peaks(1:end-1);
    end
    if R_peaks(1)-auricular < 1
        new_R_peaks=new_R_peaks(2:end);
    end
    %beat_points = auricular+ventricular;

    all_Beats = zeros(numel(new_R_peaks),beat_points+1);
    for i = 1:numel(new_R_peaks)
        inicio = new_R_peaks(i) - auricular;
        fim = new_R_peaks(i) + ventricular;
        all_Beats(i,:) = inicio:fim;
    end
    avg_Beat = mean(ecg_processed(all_Beats));

    % Metrics
    metrics.MEAN = mean(RR_interval);
    metrics.SDNN=sdnn(RR_interval)*1000;
    metrics.SDSD=sdsd(RR_interval)*1000;
    metrics.RMSSD=rmssd(RR_interval)*1000;
    [nn50,pnn50]=NNpairs(RR_interval);
    metrics.NN50=nn50;
    metrics.pNN50=pnn50;

    [pxx, f] = pburg(RR_interval, 4,2^16,fs);
    power_LF = pxx(f >= 0.04 & f < 0.15);
    power_HF = pxx(f >= 0.15 & f < 0.4);
    LF = trapz(power_LF);
    HF = trapz(power_HF);
    value_RaLH=LF/HF;
    metrics.RaLH = value_RaLH;
end
