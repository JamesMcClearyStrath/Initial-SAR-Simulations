clear 
%% Sim paramaters
c = physconst('LightSpeed');        %Speed of Light Constant
fc = 4e9;                           %SAR center frequency
rangeResolution = 3;
crossRangeResolution = 3;           %3 meters
bw = c/(2*rangeResolution);         %Derived from range res

%% Radar info
prf = 1000;
aperture = 4;
tpd = 3*10^-6;
fs = 120*10^6;

waveform = phased.LinearFMWaveform('SampleRate',fs, 'PulseWidth', tpd, 'PRF', prf,...
    'SweepBandwidth', bw);

%% Flight info
speed = 100;            %m/s
flightDuration = 4;     %s
radarPlatform  = phased.Platform('InitialPosition', [0;-200;500], 'Velocity', [0; speed; 0]);
slowTime = 1/prf;
numpulses = flightDuration/slowTime +1;

maxRange = 2500;
truncrangesamples = ceil((2*maxRange/c)*fs);
fastTime = (0:1/fs:(truncrangesamples-1)/fs);
% Set the reference range for the cross-range processing.
Rc = 1000;

%% SAR transmitter and receiver
antenna = phased.CosineAntennaElement('FrequencyRange', [1e9 6e9]);
antennaGain = aperture2gain(aperture,c/fc); 

transmitter = phased.Transmitter('PeakPower', 50e3, 'Gain', antennaGain);
radiator = phased.Radiator('Sensor', antenna,'OperatingFrequency', fc, 'PropagationSpeed', c);

collector = phased.Collector('Sensor', antenna, 'PropagationSpeed', c,'OperatingFrequency', fc);
receiver = phased.ReceiverPreamp('SampleRate', fs, 'NoiseFigure', 30);

%% Propagation Channel
channel = phased.FreeSpace('PropagationSpeed', c, 'OperatingFrequency', fc,'SampleRate', fs,...
    'TwoWayPropagation', true);

%% Environment Setup
targetpos= [800,5,0;1000,0,0; 1300,0,0]'; 

targetvel = [0,0,0;0,0,0; 0,0,0]';

target = phased.RadarTarget('OperatingFrequency', fc, 'MeanRCS', [1,1,1]);
pointTargets = phased.Platform('InitialPosition', targetpos,'Velocity',targetvel);
% The figure below describes the ground truth based on the target
% locations.
figure(1);h = axes;plot(targetpos(2,1),targetpos(1,1),'*g');hold all;plot(targetpos(2,2),targetpos(1,2),'*r');hold all;plot(targetpos(2,3),targetpos(1,3),'*b');hold off;
set(h,'Ydir','reverse');xlim([-10 10]);ylim([700 1500]);
title('Ground Truth');ylabel('Range');xlabel('Cross-Range');

%% Signal Propagation Simulation
% Define the broadside angle
refangle = zeros(1,size(targetpos,2));
rxsig = zeros(truncrangesamples,numpulses);
for ii = 1:numpulses
    % Update radar platform and target position
    [radarpos, radarvel] = radarPlatform(slowTime);
    [targetpos,targetvel] = pointTargets(slowTime);
    
    % Get the range and angle to the point targets
    [targetRange, targetAngle] = rangeangle(targetpos, radarpos);
    
    % Generate the LFM pulse
    sig = waveform();
    % Use only the pulse length that will cover the targets.
    sig = sig(1:truncrangesamples);
    
    % Transmit the pulse
    sig = transmitter(sig);
    
    % Define no tilting of beam in azimuth direction
    targetAngle(1,:) = refangle;
    
    % Radiate the pulse towards the targets
    sig = radiator(sig, targetAngle);
    
    % Propagate the pulse to the point targets in free space
    sig  = channel(sig, radarpos, targetpos, radarvel, targetvel);
    
    % Reflect the pulse off the targets
    sig = target(sig);
    
    % Collect the reflected pulses at the antenna
    sig = collector(sig, targetAngle);
    
    % Receive the signal  
    rxsig(:,ii) = receiver(sig);
    
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

%% Azimuth compression
rma_processed = helperRangeMigration(cdata,fastTime,fc,fs,prf,speed,numpulses,c,Rc);
bpa_processed = helperBackProjection(cdata,rnggrid,fastTime,fc,fs,prf,speed,crossRangeResolution,c);

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