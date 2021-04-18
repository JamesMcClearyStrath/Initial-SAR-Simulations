clear;
% wtt = c^2 wxx + f

%% Domain
Lx = 10;
dx = 0.1;
nx = fix(Lx/dx);
x = linspace(0,Lx,nx);

T = 20;

%% Field Variable
wn = zeros(nx,1);   % Currnet value
wnm1 = wn;          % n-1
wnp1 = wn;          % n+1

CFL = 1;
c = 1;
dt = CFL * dx / c;

%% Initial Conditions
%wn(49:51) = [0.1 0.2 0.1];
%wnp1(:) = wn(:);

%% Time stepping Loop 
t = 0;

while(t<T)
   % Reflecting Boundary Conditions
   wn([1 end]) = 0;
   
   % Absorbing Boundary Conditions
   %wnp1(1) = wn(2) + ((CFL-1)/(CFL + 1)) * (wnp1(2) - wn(1));
   %wnp1(end) = wn(end-1) + ((CFL-1)/(CFL+1))*(wnp1(end-1)-wn(end));
   
   %solution
   t = t+dt;
   
   wnm1 = wn;
   wn = wnp1;
   
   % Source
   %wn(50) = dt^2*20*sin(20*pi*t/T);
   wn(50) = .1*sin(20*pi*t/T);
   for i = 2:nx-1
       wnp1(i) = 2*wn(i) - wnm1(i) + CFL^2*(wn(i+1)-2*wn(i)+wn(i-1));
   end
   
   % Visualise at selected steps
   clf;
   plot(x,wn);
   title(sprintf('t=%.2f',t));
   axis([0 Lx -0.5 0.5]);
   shg;
   pause(0.01);
   
end