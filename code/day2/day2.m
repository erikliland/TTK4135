run('../init.m'); %% Endret m_g til 0.025 fra 0.012
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
Q(3,3) = 0.00;           % Free pitch 
Q(4,4) = 0;              % Free pitch rate
R  = 1;                  % Input penalty weight
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
% lb((nx+nu)*N)  = 0; %Limit last input
% ub((nx+nu)*N)  = 0; %Limit last input
f = zeros(1, n);
z = quadprog(H, f, [], [], Aeq, Beq, lb, ub);
u = z(N*nx+1:n);
% Prepeare input sequence
t = (0:N+2*n_offset-1) * h;
pitch_input = zeros(N+2*n_offset, 2);
pitch_input(:, 1) = t;
pitch_input(n_offset+1:N+n_offset, 2) = u;

%% Plot simulated system
fig = figure(1); clf(1); box on;
% set(gca,'FontSize',11)
sim_travel = z(1:nx:N*nx);
sim_pitch  = z(3:nx:N*nx);
sim_travel_w_offset=[ones(n_offset,1)*pi;sim_travel;ones(n_offset,1)*sim_travel(end)];
sim_pitch_w_offset = [zeros(n_offset,1); sim_pitch ;ones(n_offset,1)*sim_pitch(end)];
time = (0:N-1+2*n_offset)*h;
hold all;
plot(time,(180/pi)*sim_travel_w_offset,'LineWidth',2);
plot(time,(180/pi)*sim_pitch_w_offset,'LineWidth',2);
legend('Sim Travel', 'Sim Pitch');

% Plot results
load ('measurements.mat');
t_real = measurements(1,:);
travel = (180/pi)*measurements(2,:);
pitch = (180/pi)*measurements(4,:);
plot(t_real, travel, 'LineWidth', 2);
plot(t_real, pitch,  'LineWidth', 2);
xlim([0 (N*h)+2*offsetTime]); ylim([-70 210]);
line([offsetTime offsetTime],get(gca,'YLim'),'Color','Black','LineWidth',1);
line([offsetTime+N*h offsetTime+N*h],get(gca,'YLim'),'Color','Black','LineWidth',1);

ylabel('Angle (degrees)', 'Interpreter', 'Latex');
xlabel('Time (seconds)', 'Interpreter', 'Latex');
hlegend = legend('$\lambda^*$', '$p^*$', '$\lambda$', 'p', 'Location', 'NE');
title('Comparison of functions', 'Interpreter', 'Latex');

set(hlegend, 'Interpreter', 'Latex');

set(fig, 'units','centimeters');
pos = get(gcf, 'position');
set(gcf, 'position', [pos(1), pos(2), 15, 9]);


