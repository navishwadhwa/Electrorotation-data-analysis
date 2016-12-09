clc;
close all
clear

%Load the mat file containing the data. Eventually this should be in a loop
%going through all files in a cerain folder(s).
load('C:\Users\Navish\Dropbox\Electrorotation Data\11-10-16\16h_24m_15s.mat')

X_signal = UntitledVoltage_0.Data; % Contains X-Photomultiplier signal
Y_signal = UntitledVoltage_1.Data; % Contains Y-Photomultiplier signal
fs = UntitledVoltage_2.Property.wf_samples; % number of samples per sec
F_state = UntitledVoltage_2.Data; % Shows whether the field was ON or OFF
F_state = (F_state > 2); % convert to binary (0/1)
% Time = (10^-4)*(1:size(X_signal))';

Switch = [diff(F_state)]; % find if the field was switched
OnOff = find(Switch); % Indices of the switching data points

%Define pairs in sample numbers describing the times when the field was on
%and off. The first column is when the event startes and the second when it
%ended. Frequency calculated between these two.

ON_pairs = [OnOff(1:2:end) OnOff(2:2:end)];
OFF_pairs = [OnOff(2:2:end-2) OnOff(3:2:end)];

ON_cnt = (ON_pairs(3,2)-ON_pairs(3,1)); % # samples in each ON event
OFF_cnt = (OFF_pairs(3,2)-OFF_pairs(3,1)); % # samples in each OFF event
ON_dur = ON_cnt/fs; % actual duration of each ON event
OFF_dur = OFF_cnt/fs; % actual duration of each OFF event
OnOff_duration = OFF_dur + ON_dur; % Total duration of each cycle

% The matrix above missed the last OFF event immediately following the last
% ON event and before the recovery starts (two seconds after the last ON).
% Adding that bit to the Off_pairs here.
OFF_pairs = vertcat([1 OnOff(1)],OFF_pairs,[OnOff(end) OnOff(end)+(OFF_pairs(3,2)-OFF_pairs(3,1))]);

%Recovery starts when the final OFF event ends, until the end of sampling.
%Divided that section of the data into chunks of the same size as OFF
%events for frequency calculation. Then the same parameters as OFF can be
%used for REC.
REC_array = OFF_pairs(end,2):OFF_cnt:size(X_signal,1);
REC_pairs = [REC_array(1:end-1)' REC_array(2:end)'];

%Frequency calculation

FRE_ON = zeros(size(ON_pairs,1),1);
FRE_OFF = zeros(size(OFF_pairs,1),1);


T_ON = zeros(size(ON_pairs,1),1);
T_OFF = zeros(size(OFF_pairs,1),1);

%ON

for ii = 1:size(ON_pairs,1)

% apply a highpass filter on the ON data to prevent spurious low freqs from
% affecting the calculation. The ON freq in proper experiments done above 
% ~15 degree C is expected to be well above ~100 Hz. Keep the cutoff fc
% around 20-50

fc = 40; 
[b,a] = butter(6,fc/(fs/2),'high'); 

%Get the "chunk" of data for this computation
X_chunk = X_signal(ON_pairs(ii,1):ON_pairs(ii,2));
Y_chunk = Y_signal(ON_pairs(ii,1):ON_pairs(ii,2));


X_chunk = filter(b,a,X_chunk); %apply the highpass filter
Y_chunk = filter(b,a,Y_chunk); %apply the highpass filter

[pxx] = periodogram(X_chunk - mean(X_chunk), [],[],fs);
[pyy,f] = periodogram(Y_chunk - mean(Y_chunk), [],[],fs);
[~,loc] = max(pxx+pyy);
FRE_ON(ii) = f(loc);
T_ON(ii) = (mean(ON_pairs(ii,:))-ON_pairs(1,1))/fs;
% The other method to work almost equally well was pmtm (below). 
% [pxx2,f2] = pmtm(X_chunk - mean(X_chunk),1.25,[],rate);
% [~,loc] = max(pxx2);
% FRE_ON_pmtm = f2(loc)

% If needed, the power spectrum can be checked using the code below
% figure;
% plot(f,pxx)
% xlim([0 500])

end

%OFF

for ii = 1:size(OFF_pairs,1) %ON_pairs and OFF_pairs are NOT the same size

% apply a low filter on the OFF data to prevent spurious high freqs from
% affecting the calculation. The OFF freq in proper experiments done above 
% ~15 degree C is expected to be well below ~50 Hz. Keep the cutoff fc
% around 50-100 Hz

fc = 50; 
[b,a] = butter(6,fc/(fs/2),'low'); 

X_chunk = X_signal(OFF_pairs(ii,1):OFF_pairs(ii,2));
Y_chunk = Y_signal(OFF_pairs(ii,1):OFF_pairs(ii,2));

X_chunk = filter(b,a,X_chunk); %apply the lowpass filter
Y_chunk = filter(b,a,Y_chunk); %apply the lowpass filter


[pxx,f] = periodogram(X_chunk - mean(X_chunk), [],[],fs);
pyy = periodogram(Y_chunk - mean(Y_chunk), [],[],fs);
[~,loc] = max(pxx+pyy);
FRE_OFF(ii) = f(loc);
T_OFF(ii) = (mean(OFF_pairs(ii,:))-ON_pairs(1,1))/fs;

% [pxx2,f2] = pmtm(X_chunk - mean(X_chunk),1.25,[],rate);
% [~,loc] = max(pxx2);
% FRE_Off_pmtm = f2(loc)

% figure;
% subplot(3,1,1)
% plot(f,pxx)
% xlim([0 20])

end
T_OFF(1)=0; % The first one is at t = 0 in the experiment.


% REC

FRE_REC = zeros(size(REC_pairs,1),1);
T_REC = zeros(size(REC_pairs,1),1);
for jj = 1:size(REC_pairs,1) %REC_pairs are of a different size

    % apply a low filter on the REC data to prevent spurious high freqs from
% affecting the calculation. The REC freq in proper experiments done above 
% ~15 degree C is expected to be well below ~50 Hz. Keep the cutoff fc
% around 50-100 Hz

fc = 50; 
[b,a] = butter(6,fc/(fs/2),'low'); 
    
X_chunk = X_signal(REC_pairs(jj,1):REC_pairs(jj,2));
Y_chunk = Y_signal(REC_pairs(jj,1):REC_pairs(jj,2));

X_chunk = filter(b,a,X_chunk); %apply the lowpass filter
Y_chunk = filter(b,a,Y_chunk); %apply the lowpass filter


[pxx,f] = periodogram(X_chunk - mean(X_chunk), [],[],fs);
pyy = periodogram(Y_chunk - mean(Y_chunk), [],[],fs);
[~,loc] = max(pxx+pyy);
FRE_REC(jj) = f(loc);
T_REC(jj) = (mean(REC_pairs(jj,:))-ON_pairs(1,1))/fs;

% [pxx2,f2] = pmtm(X_chunk - mean(X_chunk),1.25,[],rate);
% [~,loc] = max(pxx2);
% FRE_Off_pmtm = f2(loc)

% figure;
% plot(f,pxx)


end

% Plot the ON frequency with time
% figure;
% plot(T_ON,FRE_ON,'--o')
% ylim([0 max(FRE_ON)+ (max(FRE_ON) - min(FRE_ON))])
% xlabel('Time (s)')
% ylabel('Frequency (Hz)')

% Plot the OFF frequency with time.
figure;
subplot(1,2,1)
plot(T_OFF,FRE_OFF,'--o')
xlabel('Time (s)')
ylabel('Frequency (Hz)')
title('Dissociation')

% Plot the REC frequency with time.
% figure;

subplot(1,2,2)
plot(T_REC,FRE_REC,'--o')
xlabel('Time (s)')
ylabel('Frequency (Hz)')
title('Recovery')