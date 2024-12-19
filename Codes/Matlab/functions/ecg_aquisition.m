function [all_time,all_ecg,close]=ecg_aquisition(SerialPort,all_time,all_ecg,AquisitionTime,RealTime,AquisitionFreq,graph)
    % Read the ASCII data from the serialport object.
    data = readline(SerialPort);
    if isempty(data)
        close=1;
    else
        data=split(data,'|');
        time=data(1);
        ecg_signal=data(2);

        time=str2double(time)/1000;
        ecg_signal=str2double(ecg_signal);
        all_time=[all_time,time];
        all_ecg=[all_ecg,ecg_signal];
        if RealTime==1 && (mod(length(all_ecg),round(AquisitionFreq/4))==0)
            set(graph, 'XData', [get(graph, 'XData'),all_time(end-(AquisitionFreq/4)+1:end)-all_time(1)], 'YData', [get(graph, 'YData'),all_ecg(end-(AquisitionFreq/4)+1:end)]);  % add the new data point to the plot
            drawnow;
        end

        close=0;
        if time-all_time(1)>AquisitionTime*60
            close=1;
        end
    end
end