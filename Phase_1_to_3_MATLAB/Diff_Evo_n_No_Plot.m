tic
clear, clc, close all
for kk=1:100
%% Defide bounds and critical variables
low=-7;
high=7;
dim=4;
%population size
NP=linspace(low,high,dim*4);
one=ones(1,length(NP));
for z=1:dim-1
    NP=[NP;NP(1,:)];
end
N=1:1:dim;
%Crossover probability
CR=0.9;
%Differential Weight
F=0.7;
%Define functions
%number of parameters
a=zeros(dim,1);
b=zeros(dim,1);
c=zeros(dim,1);
% syms x
s=1;
count=0;
cost2=1;
cost3=1;
%% Loops
% begin looping until the standard deviation of the set is low
while cost2>0.0001 || cost3>0.001
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
    end
    % calculate cost function
    % sub if y is better
            if abs((y(1)-1)^2+(y(2)-6)^2+(y(3))^2+(y(4)+5)^2)<...
               abs((NP(1,x(k))-1)^2+(NP(2,x(k))-6)^2+(NP(3,x(k)))^2+(NP(4,x(k))+5)^2)                
                NP(:,x(k))=y;
            end
    end
    cost2=mean(abs((NP(1,:)-1).^2+(NP(2,:)-6).^2+(NP(3,:)).^2+(NP(4,:)+5).^2));
    cost3=mean(std(NP'));
end
result=mean(NP')
kct(kk)=count;
mean(kct)
end
toc