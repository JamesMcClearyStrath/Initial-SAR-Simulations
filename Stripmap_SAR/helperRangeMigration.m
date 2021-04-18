function azcompresseddata = helperRangeMigration(sigData,fastTime,fc,fs,prf,speed,numPulses,c,Rc)

frequencyRange = linspace(fc-fs/2,fc+fs/2,length(fastTime));
krange = 2*(2*pi*frequencyRange)/c;

kaz = 2*pi*linspace(-prf/2,prf/2,numPulses)./speed;

kazimuth = kaz.';
kx = krange.^2-kazimuth.^2;

kx = sqrt(kx.*(kx > 0));
kFinal = exp(1i*kx.*Rc);

sdata =fftshift(fft(fftshift(fft(sigData,[],1),1),[],2),2);

fsmPol = (sdata.').*kFinal;

stoltPol = fsmPol;
for i = 1:size((fsmPol),1)
    stoltPol(i,:) = interp1(kx(i,:),fsmPol(i,:),krange(1,:));
end
stoltPol(isnan(stoltPol)) = 1e-30;
stoltPol = stoltPol.*exp(-1i*krange.*Rc);
azcompresseddata = ifft2(stoltPol);
end

