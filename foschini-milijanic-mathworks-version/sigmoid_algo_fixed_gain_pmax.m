%Author: Qazi Zarif Ul Islam
%email: zayanqm@gmail.com
%Discription: This code is a simulation of L users Distributed Power Control. 
% The difference to CDMA is that intra-cell
%interference. This code uses the sources of Alex Dytso(email:
%odytso2@uic.edu) and the words from book "Power Control in Wireless
%Cellular Networks"(by Mung Chiang). Thanks to both authors. 

%Discription: This code is a simulation of K user Distributed Power Control
%Algorithm:  Distributive Power control

%%
clc, clear all, clf


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% System parameter initialization
% L: number of users.
% G: channel gain of amplitude. 
% delta: belonging 
% F: nonnegative matrix. F_{lj} = G_{lj} if l ~= j, and F_{lj} = 0 if l = j
% v: nonnegative vector. v_l = 1/G_{ll}
% pmax: upper bound of the total power constraints.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

L = 3;
G = [0.8 0.9 0.6; 0.03 0.84 0.9; 0.67 0.75 0.74] % Gii are diagonal elements, Gij are off-diagonal
F = zeros(L,L); 
v = zeros(L,1);
N=0.01*ones(L,1); % Noise power at each receiver 
% specify required SIR levels at each receiver
Tau=[5;5 ;5] %target SIR at each receiver
pmax = 3 %unit mW
%%

%init G
% for l = 1:1:L
%     for j = 1:1:L
%         if l~= j
%             G(l,j) = rand(1,1);
%         else
%             G(l,j) = rand(1,1);
%         end
%     end
% end
%%

%init F v
for l = 1:1:L
    for j = 1:1:L
        if l ~= j
            F(l,j) = G(l,j)/G(l,l);
        else
            F(l,j) = 0;
        end
    end
    v(l) = N(l)*Tau(l)/G(l,l);
end





P=pmax*ones(L,1); % initial transmit Power is set to maximum power
Pt = P;
a=diag(G);D=diag(a); % D is a matrix containing only the intended link gains
SIR=D*P./(F*D*P+N);
global b c
b=2;
c=10;

%% Tests for convergence

% positivity
I = (F*D*P+N);
max_I = c.*D.*sigmoid2(Tau)./b
max_I = diag(max_I)

I = max_I - 0.001
SIR = D*P./I

% monoticity
max_I = (c.*Tau.*D)./(b.*(1+0.5))
max_I = diag(max_I)
%%
%algorithm starts here
iterations=1;
Err=ones(L,1); %some initial error value  
while iterations<30
%while max(Err(:,iterations))>0.006  % I choose maximum erro to be a divergence criteria
     
    P=((Tau./SIR(:,iterations)).*P)-sigmoid(P,SIR(:,iterations)).*P./SIR(:,iterations); % New power used by transmitters
    P = min(P,pmax);
    iterations=iterations+1;
    Pt(:,iterations) = P; % storing the new P 
    SIR(:,iterations)=D*P./(F*D*P+N);% new SIR
%     conv_condition = SIR(:,iterations)>max_I;
%     for i=1:length(conv_condition)
%         if conv_condition(i)==1
%             flag = 1;
%         end
%     end
%     if flag==1
%         disp("convergence conditions broken")
%         break
%     end
    Err(:,iterations)=abs(Tau- SIR(:,iterations)); %error

end

Err(:,end)
SIR(:,end)
P
%% Plots
% SIR
x=1:iterations;
figure(1)
plot(x,SIR(1,:),'-.',x,SIR(2,:),'-.g',x,SIR(3,:),'-.r')
 xlabel('Iterations')
 ylabel('SIR')
 title('SIR vs number of Iterations');
     legend(' SIR of user 1',' SIR of user 2',' SIR of user 3');

% power
figure(2)
plot(x,Pt(1,:),'-.',x,Pt(2,:),'-.g',x,Pt(3,:),'-.r')
 xlabel('Iterations')
 ylabel('Power')
 title('Power vs number of Iterations');
     legend(' Power of user 1',' Power of user 2',' Power of user 3');


%% table

T = table(Tau,Pt(:,1),P,SIR(:,end), VariableNames={'Tau','Initial Powers','P','Final SIR'})