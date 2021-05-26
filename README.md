# Initial-SAR-Simulations

This contains the initial code used for simulations and learning how to calculate wave propagations. 

The 1D adn 2D wave propagation examples are based off code from https://hstephen.faculty.unlv.edu/teaching-2/cee-709/

The SAR code is some example code provided by mathworks at https://www.mathworks.com/help/radar/ug/stripmap-synthetic-aperture-radar-sar-image-formation.html

1D, 2D files can be run individually, Stripmap SAR code must have both helper functions in same folder


Implemented different situational examples from - https://uk.mathworks.com/help/radar/examples.html?category=index&exampleproduct=all&s_tid=CRUX_lftnav

Currently developing simulation of Bistatic scenario, reusing code from Stripmap SAR. This is using pulsed waveforms but will be transitioned to modulated CW. DAB/DAB+ is the next waveform though also aiming to use DVB and potentially other satellite based communication channels with MHz carrier frequencies.
