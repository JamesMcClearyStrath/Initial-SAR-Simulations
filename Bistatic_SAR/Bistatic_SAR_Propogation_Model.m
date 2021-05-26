clear;
%%
c = physconst('LightSpeed');        %Speed of Light Constant
fc = 4e9;                           %SAR center frequency
rangeResolution = 3;
crossRangeResolution = 3;           %3 meters
bw = c/(2*rangeResolution);         %Derived from range res
prf = 1000;
aperture = 4;
tpd = 3*10^-6;
fs = 120*10^6;
numpulses = 1000;

maxRange = 2500;
truncrangesamples = ceil((2*maxRange/c)*fs);
fastTime = (0:1/fs:(truncrangesamples-1)/fs);
Rc = 1000;

waveform = phased.LinearFMWaveform('SampleRate',fs, 'PulseWidth', tpd, 'PRF', prf,...
    'SweepBandwidth', bw);

%%
antenna = phased.CosineAntennaElement('FrequencyRange', [1e9 6e9]);
antennaGain = aperture2gain(aperture,c/fc); 

transmitter = phased.Transmitter('PeakPower', 50e3, 'Gain', antennaGain);
radiator = phased.Radiator('Sensor', antenna,'OperatingFrequency', fc, 'PropagationSpeed', c);

collector_ref = phased.Collector('Sensor', antenna, 'PropagationSpeed', c,'OperatingFrequency', fc);
receiver_ref = phased.ReceiverPreamp('SampleRate', fs, 'NoiseFigure', 30);

collector_surv = phased.Collector('Sensor', antenna, 'PropagationSpeed', c,'OperatingFrequency', fc);
receiver_surv = phased.ReceiverPreamp('SampleRate', fs, 'NoiseFigure', 30);

channel_ref = phased.FreeSpace('PropagationSpeed', c, 'OperatingFrequency', fc,'SampleRate', fs,...
    'TwoWayPropagation', false);

channel_Tx_Target = phased.FreeSpace('PropagationSpeed', c, 'OperatingFrequency', fc,'SampleRate', fs,...
    'TwoWayPropagation', false);

channel_Target_Rx = phased.FreeSpace('PropagationSpeed', c, 'OperatingFrequency', fc,'SampleRate', fs,...
    'TwoWayPropagation', false);

target = phased.RadarTarget('OperatingFrequency', fc, 'MeanRCS', [1,1]);
%%

Tx_loc = [0 0 10]';
target_loc = [500 0 0;600 5 0]';
Rx_loc = [1000 -5 100]';

Tx_vel = [0 0 0]';
Rx_vel = [0 2 0]';
target_vel = [0 0 0;-20 0 0]';

rx_sig_ref = zeros(truncrangesamples, numpulses);
rx_sig_surv = zeros(truncrangesamples, numpulses);

for i = 1:numpulses
    %Propogation angles and info
    Tx_loc = Tx_loc + Tx_vel;
    target_loc = target_loc + target_vel;
    Rx_loc = Rx_loc + Rx_vel;
   
    [Tx_Target_range, Tx_Target_angle] = rangeangle(target_loc,Tx_loc); 
   [Target_Rx_range, Target_Rx_angle] = rangeangle(Rx_loc, target_loc);
   [Tx_Rx_range, Tx_Rx_angle] = rangeangle(Rx_loc, Tx_loc);
    
   %transmit signal
   
   sig_ref = waveform();
   sig_surv = waveform();
   
   sig_ref = sig_ref(1:truncrangesamples);
   sig_surv = sig_surv(1:truncrangesamples);
   
   sig_ref = transmitter(sig_ref);
   sig_surv = transmitter(sig_surv);
   %target_angle(1,:) = refangle;
   sig_ref = radiator(sig_ref, Tx_Rx_angle);
   sig_surv = radiator(sig_surv, Tx_Target_angle);
   
   sig_ref  = channel_ref(sig_ref, Tx_loc, Rx_loc, Tx_vel, Rx_vel);
   
   sig_surv = channel_Tx_Target(sig_surv, Tx_loc, target_loc, Tx_vel, target_vel);
   sig_surv = target(sig_surv);
   sig_surv = channel_Target_Rx(sig_surv,target_loc, Rx_loc, target_vel, Rx_vel);
   
   sig_ref = collector_ref(sig_ref, Tx_Rx_angle);
   sig_surv = collector_surv(sig_surv, Target_Rx_angle);
   
   rx_sig_ref(:,i) = receiver_ref(sig_ref);
   rx_sig_surv(:,i) = receiver_surv(sig_surv);
     
    
end

%% Visualise Raw Received signal
figure;
imagesc(real(rxsig));title('SAR Raw Data')
xlabel('Cross-Range Samples')
ylabel('Range Samples')

%% Range compression and matched filtering
pulseCompression = phased.RangeResponse('RangeMethod', 'Matched filter', 'PropagationSpeed', c, 'SampleRate', fs);
matchingCoeff = getMatchedFilter(waveform);
[cdata, rnggrid] = pulseCompression(rxsig, matchingCoeff);
figure;
imagesc(real(cdata));title('SAR Range Compressed Data')
xlabel('Cross-Range Samples')
ylabel('Range Samples')

%% Azimuth compression - currently throws error for this code, still debugging why

rma_processed = helperRangeMigration(cdata,fastTime,fc,fs,prf,Rx_vel(2),numpulses,c,Rc);
bpa_processed = helperBackProjection(cdata,rnggrid,fastTime,fc,fs,prf,Rx_vel(2),crossRangeResolution,c);

figure(4);
imagesc((abs((rma_processed(1700:2300,600:1400).'))));
title('SAR Data focused using Range Migration algorithm ')
xlabel('Cross-Range Samples') 
ylabel('Range Samples')

figure(5)
imagesc((abs(bpa_processed(600:1400,1700:2300))));
title('SAR Data focused using Back-Projection algorithm ')
xlabel('Cross-Range Samples')
ylabel('Range Samples')

%% plotting - used to plot scene as targets/platform moves - not really needed
% for i = 1:num_pulses
% figure(1);
% h = axes;
% hold on;
% plot(Tx_loc(2),Tx_loc(1),'X');
% plot(target_loc(1,2),target_loc(1,1),'*r');
% plot(target_loc(2,2),target_loc(2,1),'*r');
% plot(Rx_loc(2),Rx_loc(1),'*b');
% hold off;
% set(h,'Ydir','reverse');
% xlim([-10 10]);
% %ylim([700 1500]);
% 
% Rx_loc = Rx_loc + Rx_vel;
% target_loc(1,:) = target_loc(1,:) + target_1_vel;
% target_loc(2,:) = target_loc(2,:) + target_2_vel;
% end

