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
    y=max(y,0);
        end
    %run the heat transfer code for the new value
    T1=Heat_transfer(y');
    %save new results
    K1=[T1(5,5),T1(18,15),T1(16,9),T1(8,16)];
    % calculate value of the cost function for each set
    new=(K1(1)-T(1))^2+(K1(2)-T(2))^2+(K1(3)-T(3))^2+(K1(4)-T(4))^2;
    old=(NPstore(1,x(k))-T(1))^2+(NPstore(2,x(k))-T(2))^2+(NPstore(3,x(k))-T(3))^2+(NPstore(4,x(k))-T(4))^2;
            if new<old
                NP(:,x(k))=y; NPstore(:,x(k))=K1;
            end
    end
    cost2=mean((NPstore(1,:)-T(1)).^2+(NPstore(2,:)-T(2)).^2+(NPstore(3,:)-T(3)).^2+(NPstore(4,:)-T(4)).^2);
    cost3=mean(std(NP'));
end
result=mean(NP,2)
toc

