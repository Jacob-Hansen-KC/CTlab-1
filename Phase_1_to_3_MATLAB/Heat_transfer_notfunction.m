tic
clear, clc, close all
delete heat.gif
gif('heat.gif')
%% define simple constants
%define thermal diffusivity (edit based on material)
%aluminum
a=97; %mm^2/s 
alpha=a/1000^2; %m^2/s

%define area matrix, length, time parameters (cm per side)
s=50; %(edit based on area)

%edit based on persision
%delta_x %delta_y (m)
dx=0.01; dy=0.01;
%L_x %L_y (m)
Lx=0:0.01:(s-1)*dx; Ly=0:0.01:(s-1)*dy;
[X,Y]=meshgrid(Lx,Ly);
%delta_t (sec)
dt=0.1;

%% define initial and redefine Temperature, and heat source term
T2=ones(s+2)*273.15; %K
[P,Q]=size(T2);
T1=zeros(s+2);

%S=rand(s+2)*30;
S=zeros(s+2);%define S(heat source) array
S(25,25)=100;
k=0;
value=1;
%% boundary conditions
%edges left bottom right top
bdry=[500 300 200 700];
T2(:,1)=bdry(1); T2(1,:)=bdry(2); T2(:,end)=bdry(3); T2(end,:)=bdry(4);  
% k<1200 &
%% Define Loop
while value>0.005
    T1=T2; % set the 2 temp plots equal
       i=2:P-1; %sweep x axis
        j=2:Q-1; %sweep y axis
            %Impliment Explicit Eular Scheme
            T2(i,j)=T1(i,j)+alpha*dt*((T1(i+1,j)-2*T1(i,j)+T1(i-1,j))/dx^2+...
                (T1(i,j+1)-2*T1(i,j)+T1(i,j-1))/dy^2)+S(i,j)*dt; 
%increase tick
k=k+1;
% reimplement boundary conditions
T2(:,1)=bdry(1); T2(1,:)=bdry(2); T2(:,end)=bdry(3); T2(end,:)=bdry(4);
% Update plot
    if rem(k,10)==0
    contourf(Lx,Ly,T2(2:end-1,2:end-1),20)
    % surf(Lx,Ly,T2(2:end-1,2:end-1))
    title(k*dt,"(Sec)")
    c=colorbar;
    c.Label.String='Temperature (K)'; clim([min(bdry), max(bdry)]), xlabel('X (m)'); ylabel('Y (m)'); zlabel('T (K)');
    colormap jet
    drawnow

    gif
    end
    value=abs(mean(T2-T1,"all"));
end
contourf(Lx,Ly,T2(2:end-1,2:end-1),20)
c=colorbar;
c.Label.String='Temperature (K)'; clim([min(bdry), max(bdry)]), xlabel('X (m)'); ylabel('Y (m)'); zlabel('T (K)');
% surf(Lx,Ly,T2(2:end-1,2:end-1))
title(k*dt,"(Sec)")
toc
% hold on
%   x=[0.05-0.02 0.15-0.02 0.09-0.02 0.16-0.02];
%     y=[0.05-0.02 0.18-0.02 0.16-0.02 0.06];
%     plot(x, y, 'k.', 'LineWidth', 2, 'MarkerSize', 20)
% colormap jet
