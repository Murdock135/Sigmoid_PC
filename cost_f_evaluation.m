clc;
clear;

UEd = 4; % 2 D2D devices (1 pair)
UEc = 1; % 1 cellular devices
%% distances between communication pairs [m]

d_ii = 20; % distance between "intended" or communicating d2d devices i->i
d_ij = 35; % distance between "unintended" or non-communicating d2d devices i->j
dcb = 50; % distance between cellular and base-station
d_ik = 50; % distance between d2d and cellular 
%% UE link quality

% power vector of all users
pi = 0.02; % power vector of D2D user i [W]
pk = ones(UEc,1)*0.02; % power vector of Cellular user k (fixed) [W]
pj = ones(UEd-2,1)*0.02; % power vector of p(-i) or jth d2d user [w]
n = 0.0001; % noise
% channel gains
gii(1,1) = 1.*(100./d_ii).^2; % link gain from ith d2d to ith d2d device (assuming correlation coef =1)(assuming constant)
gij = 1.*(100./d_ij).^2.*ones(UEd-2,1); % link gain from jth d2d to ith d2d device (assuming correlation coef =1)(assuming constant)
gik = 1.*(100./d_ik).^2; % link gain between d2d and cellular devices


%%  algorithm parameters

pmax = 1000e-3; % 1000 mW
tau = 5; % target SIR is 5 

% sigmoid parameters
b = 2;
c = 10;
%% Evaluation of cost function
Id(1) = 0;
SIR(1,1) = 0;
J(1) = 0;

% J vs gii
i=1;
while gii(1,i)<200
    I = pk*gik+pj'*gij+n;
    SIR(1,i) = pi*gii(1,i)/I;
    J(i) = (2*gii(1,i)/I).*sigmoid(I,gii(1,i))+c.*(tau-SIR(1,i))^2;
    gii(1,i+1) = gii(1,i) +1;
    i = i+1;
end
gii = gii(1,1:i-1);
%% plots
figure(1)
plot(gii(:),J)