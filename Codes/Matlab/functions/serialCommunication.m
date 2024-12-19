function serialCommunication(pacient_ID,AquisitionTime,AquisitionFreq,RealTime,app)
    % MATLAB Code for Serial Communication between Arduino and MATLAB
    % Creation of SerialPort
    COMlist=serialportlist("available");
    if ~isempty(COMlist)
        load("AllPatients.mat","AllPatients");
        n_aquisitions=numel(fieldnames(AllPatients.("Patient"+pacient_ID).ECG_Aquisitions))+1;
        AllPatients.("Patient"+pacient_ID).ECG_Aquisitions.("Aquisition"+n_aquisitions).ECG= [];
        AllPatients.("Patient"+pacient_ID).ECG_Aquisitions.("Aquisition"+n_aquisitions).Time= [];
        AllPatients.("Patient"+pacient_ID).ECG_Aquisitions.("Aquisition"+n_aquisitions).AquisitionDate=datetime;
        AllPatients.("Patient"+pacient_ID).ECG_Aquisitions.("Aquisition"+n_aquisitions).AquisitionFreq=AquisitionFreq;
        AllPatients.("Patient"+pacient_ID).ECG_Aquisitions.("Aquisition"+n_aquisitions).AquisitionTime=AquisitionTime;
        save("AllPatients.mat","AllPatients")
        SerialPort=serialport(COMlist(1),115200);
        configureTerminator(SerialPort,"CR/LF");
        flush(SerialPort);
        SerialPort.UserData = struct("Data",[],"Count",1);
        fprintf(SerialPort,AquisitionTime+"|"+AquisitionFreq); % send answer to arduino
        pause(2.5)
        all_time=[];
        all_ecg=[];
        graph=plot(NaN,NaN,'r','Parent',app);
        title(app,"ECG Signal - Gross Analysis")
        xlabel(app,"Time (ms)")
        ylabel(app,"Potential (mV)")

        close=0;
        while close==0
            [all_time,all_ecg,close]=ecg_aquisition(SerialPort,all_time,all_ecg,AquisitionTime,RealTime,AquisitionFreq,graph);
            if RealTime==1
                if all_time(end)-all_time(1)>=2 && all_time(end)-all_time(1)+2<AquisitionTime*60
                    xlim(app,[all_time(end)-all_time(1)-2,all_time(end)-all_time(1)+2])
                elseif all_time(end)-all_time(1)+2>=AquisitionTime*60
                    xlim(app,[AquisitionTime*60-4,AquisitionTime*60])
                else
                    xlim(app,[0,4])
                end
                ylim(app,[min(all_ecg)-100,max(all_ecg)+100])
            end
        end
        
        %Convert the ECG  type and save it in the UserData
        % property of the serialport object.
        load("AllPatients.mat","AllPatients");
        n_aquisitions=numel(fieldnames(AllPatients.("Patient"+pacient_ID).ECG_Aquisitions));
        AllPatients.("Patient"+pacient_ID).ECG_Aquisitions.("Aquisition"+n_aquisitions).ECG=all_ecg; 
        
        % Update the Aquisition value of the serialport object.
        AllPatients.("Patient"+pacient_ID).ECG_Aquisitions.("Aquisition"+n_aquisitions).Time=all_time;
        if round(1/mean(all_time(2:end)-all_time(1:end-1)))<AquisitionFreq-2 || round(1/mean(all_time(2:end)-all_time(1:end-1)))>AquisitionFreq+2
            AllPatients.("Patient"+pacient_ID).ECG_Aquisitions.("Aquisition"+n_aquisitions).AquisitionFreq=round(1/mean(all_time(2:end)-all_time(1:end-1)));
        end
        [ecg_processed,~,~,ecg_energy,~,Peaks,beats_min,all_Beats,avg_Beat,beat_points,RR_interval,metrics]=ecg_processing(all_time,all_ecg,AquisitionFreq,0.1,30,[5,25],0.2);
        AllPatients.("Patient"+pacient_ID).ECG_Info.("Aquisition"+n_aquisitions).ECG_Processed=ecg_processed;
        AllPatients.("Patient"+pacient_ID).ECG_Info.("Aquisition"+n_aquisitions).ECG_Energy=ecg_energy;
        AllPatients.("Patient"+pacient_ID).ECG_Info.("Aquisition"+n_aquisitions).ECG_Peaks=Peaks;
        AllPatients.("Patient"+pacient_ID).ECG_Info.("Aquisition"+n_aquisitions).ECG_Beats_minute=beats_min;
        AllPatients.("Patient"+pacient_ID).ECG_Info.("Aquisition"+n_aquisitions).ECG_All_Beats=all_Beats;
        AllPatients.("Patient"+pacient_ID).ECG_Info.("Aquisition"+n_aquisitions).ECG_Avg_Beat=avg_Beat;
        AllPatients.("Patient"+pacient_ID).ECG_Info.("Aquisition"+n_aquisitions).ECG_Beat_Points=beat_points;
        AllPatients.("Patient"+pacient_ID).ECG_Info.("Aquisition"+n_aquisitions).ECG_RR_Intervals=RR_interval;
        AllPatients.("Patient"+pacient_ID).ECG_Info.("Aquisition"+n_aquisitions).ECG_Metrics=metrics;
        save("AllPatients.mat","AllPatients");

        % Small Diagnostics
        diagnostic(pacient_ID,n_aquisitions)
    else
        warndlg("None COM at the moment!")
    end
end
