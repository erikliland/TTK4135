% ********************************************************
% *                                                      *
% *       Optimization and Control                       *
% *                                                      *
% *       Helikopterlab                                  *
% *                                                      *
% * MAIN1NY.m                                            *
% *                                                      *
% *                                                      *
% * Updated on 04/2009 by Agus Ismail Hasan              *
% *                                                      *
% ********************************************************

initF;
delta_t	  = 0.25;	                    % sampling time
sek_forst = 5;

% System model. x=[lambda r p p_dot]'

A1 = [];
B1 = [];

% Number of states and inputs

mx = size(A1,2);                        % Number of states (number of columns in A)
mu = size(B1,2);                        % Number of inputs(number of columns in B)

% Initial values

x1_0 = ;                              % Lambda
x2_0 = ;                               % r
x3_0 = ;                               % p
x4_0 = ;                               % p_dot
x0   = [x1_0 x2_0 x3_0 x4_0]';          % Initial values

% Time horizon and initialization

N  = 60;                                % Time horizon for states
M  = N;                                 % Time horizon for inputs
z  = zeros(N*mx+M*mu,1);                % Initialize z for the whole horizon
z0 = z;                                 % Initial value for optimization

% Bounds

ul 	    = -30*pi/180;                   % Lower bound on control -- u1
uu 	    = 30*pi/180;                    % Upper bound on control -- u1

xl      = -Inf*ones(mx,1);              % Lower bound on states (no bound)
xu      = Inf*ones(mx,1);               % Upper bound on states (no bound)
xl(3)   = ul;                           % Lower bound on state x3
xu(3)   = uu;                           % Upper bound on state x3

% Generate constraints on measurements and inputs

[vlb,vub]       = ;
vlb(N*mx+M*mu)  = 0;                    % We want the last input to be zero
vub(N*mx+M*mu)  = 0;                    % We want the last input to be zero

% Generate the matrix Q and the vector c (objecitve function weights in the QP problem) 

Q1 = zeros(mx,mx);
Q1(1,1) = ;                             % Weight on state x1
%Q1(2,2) = ;                            % Weight on state x2
Q1(3,3) = ;                             % Weight on state x3
%Q1(4,4) = ;                            % Weight on state x4
P1 = 0;                                 % Weight on input
Q = 2*genq2(Q1,P1,N,M,mu);              % Generate Q
c = zeros(N*mx+M*mu,1);                 % Generate c

% Generate system matrixes for linear model

Aeq = ;           % Generate A
beq = ;        	        % Generate b
beq(1:mx) = A1*x0; 	        	        % Initial value

% Solve Qp problem with linear model
tic
[z,lambda] = ;
t1=toc;

% Calculate objective value

phi1 = 0.0;
PhiOut = zeros(N*mx+M*mu,1);
for i=1:N*mx+M*mu
  phi1=phi1+Q(i,i)*z(i)*z(i);
  PhiOut(i) = phi1;
end

% Extract control inputs and states

u  = [z(N*mx+1:N*mx+M*mu);z(N*mx+M*mu)]; % Control input from solution

x1 = [x0(1);z(1:mx:N*mx)];              % State x1 from solution
x2 = [x0(2);z(2:mx:N*mx)];              % State x2 from solution
x3 = [x0(3);z(3:mx:N*mx)];              % State x3 from solution
x4 = [x0(4);z(4:mx:N*mx)];              % State x4 from solution

Antall = 5/delta_t;
Nuller = zeros(Antall,1);
Enere  = ones(Antall,1);

u   = [Nuller; u; Nuller];
x1  = [pi*Enere; x1; Nuller];
x2  = [Nuller; x2; Nuller];
x3  = [Nuller; x3; Nuller];
x4  = [Nuller; x4; Nuller];

%save trajektor1ny

% figure
t = 0:delta_t:delta_t*(length(u)-1);                % real time

figure(2)
subplot(511)
stairs(t,u),grid
ylabel('u')
subplot(512)
plot(t,x1,'m',t,x1,'mo'),grid
ylabel('lambda')
subplot(513)
plot(t,x2,'m',t,x2','mo'),grid
ylabel('r')
subplot(514)
plot(t,x3,'m',t,x3,'mo'),grid
ylabel('p')
subplot(515)
plot(t,x4,'m',t,x4','mo'),grid
xlabel('tid (s)'),ylabel('pdot')
