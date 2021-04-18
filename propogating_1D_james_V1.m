clear;

size = 150;
source_loc = [30 130];
receiver_loc = 60;
x = linspace(0,size-1,size);
environment = zeros(1,size);
left_prop = zeros(1,size);
right_prop = zeros(1,size);
t = 0:.1:10-0.1;
T = 10;

wave = sin(10*pi*t/T);          %Pre-Calculate the wave
time = 0;
j = 1;
while(time<9.9)

    %Use 2 vectors for each direction of propogation, allows theoretically
    %infinite sources, will later allow reflection
    
    right_prop(source_loc) = wave(j)+0.99*right_prop(source_loc-1);
    left_prop(source_loc) = wave(j)+0.99*left_prop(source_loc+1);
    
    
    
    %Calculate right propogation
    for i = size:-1:2
       right_prop(i) = 0.99*right_prop(i-1);  
    end
    
    %Calculate left propogation
    for i = 1:1:size-1
       left_prop(i) = 0.99*left_prop(i+1);  
    end
    
    environment = right_prop+left_prop;
    rec_val = left_prop(60);
    clf;
    plot(x,environment);
    title(sprintf("Receiver: %f",rec_val));
    axis([0 size -1.5 1.5]);
    
    pause(0.01);
    time = time + 0.1;
    j = j+1;
end