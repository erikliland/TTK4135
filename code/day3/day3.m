run('../init.m');

% Adjustable parameters
x0 = [pi 0 0 0]';        % Initial state
h  = 0.25;               % Discretization timestep
N  = 100;                % Length of horizon
nx = 4;                  % Number of states of system
nu = 1;                  % Number of inputs of system
offsetTime = 5;          % Init time at start of simulation
n_offset = offsetTime/h; % Deadzone at start and end (timesteps)
Q = eye(nx);             % State penalty weights
Q(2,2) = 0;              % Free travel rate 
Q(3,3) = 1;              % Non-Free pitch
Q(4,4) = 0;              % Free pitch rate
R  = eye(nu);            % Input penalty weight

% System state and input bounds
pitch_lim = 30*pi/180;
x_max = [+inf +inf +pitch_lim +inf]';
x_min = [-inf -inf -pitch_lim -inf]';
u_max = +pitch_lim;
u_min = -pitch_lim;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

n  = N * (nx + nu); % Length of manipulation variable vector

% Continuous-time system matrices
Ac = [0 1     0         0 ;
      0 0   -K_2        0 ;
      0 0     0         1 ;
      0 0 -K_1*K_pp -K_1*K_pd];
  
Bc = [0 ; 0 ; 0 ; K_1*K_pp];

% Discrete-time system matrices
A = eye(4) + h * Ac;
B = h * Bc;

% Generate equality constraints matrix
Aeq = gena2(A, B, N, nx, nu);

% Generate righthand side of equality constraints
Beq       = zeros(N*nx, 1);
Beq(1:nx) = A*x0;

% Generate quadratic objective matrix
H = genq2(Q, R, N, N, nu);

% Solve QP
[lb, ub] = genbegr2(N, N, x_min, x_max, u_min, u_max);
lb(nx*(N-1)+1) = 0; %Limit last state
ub(nx*(N-1)+1) = 0; %Limit last state
f = zeros(1, n);
z = quadprog(H, f, [], [], Aeq, Beq, lb, ub);
u = z(N*nx+1:n);

% LQR
Q_LQR = diag([1 4 1 1]);
R_LQR = eye(nu);
[K, S, E] = dlqr(A,B,Q_LQR,R_LQR);

% Plot simulated system
figure(1); clf(1);
sim_travel = z(1:nx:N*nx);
sim_pitch  = z(3:nx:N*nx);
time = (0:N-1+2*n_offset)*h;
hold all;
plot(time, (180/pi)*[ones(n_offset,1)*pi ; sim_travel ; ones(n_offset,1)*sim_travel(end)], 'LineWidth', 2);
plot(time, (180/pi)*[zeros(n_offset,1) ; sim_pitch ; ones(n_offset,1)*sim_pitch(end)], 'LineWidth', 2);
legend('Travel', 'Pitch','Location','North');
line([offsetTime offsetTime],get(gca,'YLim'),'Color','Black','LineWidth',1);
line([offsetTime+N*h offsetTime+N*h],get(gca,'YLim'),'Color','Black','LineWidth',1);
axis square;
box  on;
xlim([0 (N+2*n_offset)*h]);
xlabel('Time [s]');
ylabel('Agle [deg]');
title(sprintf('Simulation of system over %d-length horizon', N));

% Create Simulink inputs
t = (0:N+2*n_offset-1) * h;
u_star = zeros(N+2*n_offset, 2);
u_star(:, 1) = t;
u_star(n_offset+1:N+n_offset, 2) = u;
x_star = zeros(N+2*n_offset, nx+1);
x_star(:, 1) = t;
%TODO: Check initial state from 0 to n_offset.
% Change to pi (x0)
x_star(n_offset+1:N+n_offset, 2) = z(1:4:N*nx);
x_star(n_offset+1:N+n_offset, 3) = z(2:4:N*nx);
x_star(n_offset+1:N+n_offset, 4) = z(3:4:N*nx);
x_star(n_offset+1:N+n_offset, 5) = z(4:4:N*nx);
figure(2)
plot(x_star(:,1), x_star(:,2) , x_star(:,1), x_star(:,3) ,x_star(:,1), x_star(:,4) ,x_star(:,1), x_star(:,5));
legend('Travel','Travel rate','Pitch','Pitch rate')

%% Plot results
figure(1);
load ('measurements.mat');
t = measurements(1,:);
travel = (180/pi)*measurements(2,:);
pitch = (180/pi)*measurements(4,:);
plot(t,travel, 'LineWidth', 2,'LineStyle','--');
plot(t, pitch, 'LineWidth', 2, 'LineStyle', '--');
legend('Sim Travel', 'Sim Pitch','Real Travel', 'Real Pitch');
xlabel('Time [s]');
ylabel('Angle [deg]');
title('Simulated optimal trajectory without feedback');
axis square;
box  on;
