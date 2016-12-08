clc;
close all

X_signal = UntitledVoltage_0.Data; % Contains X-Photomultiplier signal
Y_signal = UntitledVoltage_1.Data; % Contains Y-Photomultiplier signal
rate = UntitledVoltage_2.Property.wf_samples; % number of samples per sec
F_state = UntitledVoltage_2.Data; % Shows whether the field was ON or OFF
F_state = (F_state > 2); % convert to binary (0/1)
Time = (10^-4)*(1:size(X_signal))';

Switch = [-1;diff(F_state)]; % find if the field was switched
OnOff = find(Switch); % Indices of the switching data points
Off_pairs = [OnOff(1:2:end) [OnOff(2:2:end);size(X_signal,1)]];
On_pairs = [OnOff(2:2:end) OnOff(3:2:end)];

%Frequency

Index = 20;

%ON
X_chunk = X_signal(On_pairs(Index,1):On_pairs(Index,2));
Y_chunk = Y_signal(On_pairs(Index,1):On_pairs(Index,2));

[pxx,f] = periodogram(X_chunk - mean(X_chunk), [],[],rate);
[~,loc] = max(pxx);
FRE_ON_per = f(loc)

[pxx1,f1] = pwelch(X_chunk - mean(X_chunk),[],[],[],rate);
[~,loc] = max(pxx1);
FRE_ON_pwelch = f1(loc)

[pxx2,f2] = pmtm(X_chunk - mean(X_chunk),1.25,[],rate);
[~,loc] = max(pxx2);
FRE_ON_pmtm = f2(loc)

figure;
subplot(3,1,1)
plot(f,pxx)
xlim([150 250])
subplot(3,1,2)
plot(f1,pxx1)
xlim([150 250])
subplot(3,1,3)
plot(f2,pxx2)
xlim([150 250])


%Off
X_chunk = X_signal(Off_pairs(Index,1):Off_pairs(Index,2));
Y_chunk = Y_signal(Off_pairs(Index,1):Off_pairs(Index,2));

[pxx,f] = periodogram(X_chunk - mean(X_chunk), [],[],rate);
[~,loc] = max(pxx);
FRE_Off_per = f(loc)

[pxx1,f1] = pwelch(X_chunk - mean(X_chunk),[],[],[],rate);
[~,loc] = max(pxx1);
FRE_Off_pwelch = f1(loc)

[pxx2,f2] = pmtm(X_chunk - mean(X_chunk),1.25,[],rate);
[~,loc] = max(pxx2);
FRE_Off_pmtm = f2(loc)

figure;
subplot(3,1,1)
plot(f,pxx)
xlim([0 20])
subplot(3,1,2)
plot(f1,pxx1)
xlim([0 20])
subplot(3,1,3)
plot(f2,pxx2)
xlim([0 20])