clear, clc, close all
tic
for kk=1:1
%% define simple constants
%define thermal diffusivity (edit based on material)
%aluminum
a=97; %mm^2/s 
alpha=a/1000^2; %m^2/s

%define area matrix, length, time parameters (cm per side)
s=600; %(edit based on area)

%edit based on persision
%delta_x %delta_y (m)
dx=0.01; dy=0.01;
%delta_t (sec)
%dt=1/(4)*dx^2/alpha;
dt=0.25;

%% define initial and redefine Temperature, and heat source term
T2=ones(s+2)*273.15; %K
[P,Q]=size(T2);
T1=zeros(s+2);

%S=rand(s+2)*30;
S=zeros(s+2);%define S(heat source) array
% S(25,25)=100;
k=0;
value=1;
%% boundary conditions
%edges left bottom right top
bdry=[500 200 300 700];
T2(:,1)=bdry(1); T2(1,:)=bdry(2); T2(:,end)=bdry(3); T2(end,:)=bdry(4);  
% k<1200 &
%% Define Loop
while value>0.003
    % alt end condition
    T1=T2; % set the 2 temp plots equal
       i=2:P-1; %sweep x axis
        j=2:Q-1; %sweep y axis
            %Impliment Explicit Eular Scheme
            T2(i,j)=T1(i,j)+alpha*dt*((T1(i+1,j)-2*T1(i,j)+T1(i-1,j))/dx^2+...
                (T1(i,j+1)-2*T1(i,j)+T1(i,j-1))/dy^2)+S(i,j)*dt; 
%increase tick
k=k+1;
value=abs(mean(T2-T1,"all"));
end
end
toc
