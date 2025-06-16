tic
clear, clc, close all
%% Defide bounds and critical variables
low=260;
high=310;
dim=4;
%population size
NP=linspace(low,high,dim*4);
one=ones(1,length(NP));
for z=1:dim-1
    NP=[NP;NP(1,:)];
end
NPstore=NP*1000;
N=1:1:dim;
%Crossover probability
CR=0.9;
%Differential Weight
F=0.8;
%Define functions
%number of parameters
a=zeros(dim,1);
b=zeros(dim,1);
c=zeros(dim,1);
s=10;
count=0;
cost2=1;
cost3=1;
T=[277 283 280 280];
%initial plot
    plot(one,NP(1,:),'k.',one*2,NP(2,:),'r.',one*3,NP(3,:),'b.',one*4,NP(4,:),'g.')
    xlim([0,dim+1]), ylim([low, high])
    grid on
    grid minor
    title(count, 'iterations')
    ylabel('Temperature (K)'), xlabel('Dimensions')
    legend('left', 'bottom' ,'right', 'top',Location='best')
    drawnow
%% Loops
% begine looping for set number of iterations
while cost2>0.01 || cost3>0.05 
    count=1+count;
    % Find agents and reset trigger variables
    x = randperm(length(NP),5);
    %Sweep all agents
    for k=1:length(x)
    %find a b c and rerun if values are the same
    NP2=NP;
    % exclude X from the a b c selection
    NP2(:,x(k))=[];
    % Select a number of a b c values and organize in arrays
        idx=randperm(length(NP2),dim*3);
        for l=1:dim
        r=l*3-2;
        a(l)=NP2(l,idx(r));
        r=l*3-1;
        b(l)=NP2(l,idx(r));
        r=l*3;
        c(l)=NP2(l,idx(r));
        end
    %select a random value between 0 and 1
        for i=1:dim
        r=rand(1);
    %set the value of the y candidate
    if r<CR || i==N(i)
        y(i)=a(i)+F.*(b(i)-c(i));
    else
        y(i)=NP(i,x(k));
    end
    % y=max(y,0);
        end
    %run the heat transfer code for the new value
    T1=Heat_transfer(y');
    %save new results
    K1=[T1(5,5),T1(18,15),T1(16,9),T1(8,16)];
    % calculate value of the cost function for each set
    new=(K1(1)-277)^2+(K1(2)-283)^2+(K1(3)-280)^2+(K1(4)-280)^2;
    old=(NPstore(1,x(k))-277)^2+(NPstore(2,x(k))-283)^2+(NPstore(3,x(k))-280)^2+(NPstore(4,x(k))-280)^2;
            if new<old
                NP(:,x(k))=y; NPstore(:,x(k))=K1;
            end
    end
    if count>500
        s=10;
        if count>1000
            s=10;
        end
    end
    if rem(count,s)==0
    plot(one,NP(1,:),'k.',one*2,NP(2,:),'r.',one*3,NP(3,:),'b.',one*4,NP(4,:),'m.')
    xlim([0,dim+1]), ylim([low, high])
    grid on
    grid minor
    title(count, 'Iterations')
    ylabel('Temperature (K)'), xlabel('Dimensions')
    legend('Left Boundary', 'Bottom Boundary' ,'Right Boundary', 'Top Boundary',Location='best')
    drawnow
    end
    cost2=mean((NPstore(1,:)-277).^2+(NPstore(2,:)-283).^2+(NPstore(3,:)-280).^2+(NPstore(4,:)-280).^2);
    cost3=mean(std(NP'));
    costlist(count)=cost2;
end
result=mean(NP,2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Produce gif of final results
%% define simple constants
%define thermal diffusivity (edit based on material)
%aluminum
a=97; %mm^2/s 
alpha=a/1000^2; %m^2/s

%define area matrix, length, time parameters (cm per side)
s=20; %(edit based on area)

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
S(12,3)=10;
k=0;

%% boundary conditions
%edges left bottom right top
bdry=result;
T2(:,1)=bdry(1); T2(1,:)=bdry(2); T2(:,end)=bdry(3); T2(end,:)=bdry(4);  

%% Define Loop
figure
while k<1200 %& abs(sum(T1,"all")-sum(T2,'all'))>0.1
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
    hold on
    x=[0.05-0.02 0.15-0.02 0.09-0.02 0.16-0.02];
    y=[0.05-0.02 0.18-0.02 0.16-0.02 0.06];
    plot(x, y, 'k.', 'LineWidth', 2, 'MarkerSize', 20)
    drawnow
    end
end
figure 
count2=15:1:count;
loglog(count2,costlist(15:end)),xlabel('Iteration'), ylabel('Average cost function value')
title('Progress over iterations')
toc
