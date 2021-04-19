clear;

Fs = 1000;
dt = 1/Fs;
FDev =  50;
t = 0:dt:0.5;

Fc = 200;
x = sin(2*pi*t*30);

obw(x,Fs);
%% AM Modulation

am_mod = ammod(x,Fc,Fs);
plot(am_mod);
obw(am_mod,Fs);
%% FM Modulation

fm_mod = fmmod(x,Fc,Fs,FDev);
plot(fm_mod);