run('../init.m');

% Adjustable parameters
x0 = [pi 0 0 0]';        % Initial state
h  = 0.25;               % Discretization timestep
N  = 100;                % Length of horizon
nx = 4;                  % Number of states of system
nu = 1;                  % Number of inputs of system
offsetTime = 5;          % Init time at start of simulation
n_offset = offsetTime/h; % Deadzone at start and end (timesteps)
Q = diag([1 0 0 0]);     % State penalty weights in optimization QP
R = diag([2]);           % Input cost in optimization QP

% System state and input bounds
pitch_lim = 30*pi/180;
pitch_rate_lim = 30*pi/180;
x_max = [+inf +inf +pitch_lim +pitch_rate_lim]';
x_min = [-inf -inf -pitch_lim -pitch_rate_lim]';
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
ub(nx*(N-1)+1) = 0*pi/180; % Limit last state
lb(nx*(N-1)+1) = 0*pi/180; % Limit last state
f = zeros(1, n);
z = quadprog(H, f, [], [], Aeq, Beq, lb, ub);
u = z(N*nx+1:n);

% LQR
Q_LQR = diag([1 1 1 1]);
R_LQR = eye(nu);
[K, S, E] = dlqr(A,B,Q_LQR,R_LQR);

% Create Simulink inputs
t = (0:N+2*n_offset-1) * h;
u_star = zeros(N+2*n_offset, 2);
u_star(:, 1) = t;
u_star(n_offset+1:N+n_offset, 2) = u;
x_star = zeros(N+2*n_offset, nx+1);
x_star(:, 1) = t;
x_star(1:n_offset, 2) = pi * ones(n_offset, 1);
x_star(n_offset+1:N+n_offset, 2) = z(1:4:N*nx);
x_star(N+n_offset+1:N+2*n_offset, 2) = x_star(n_offset+N, 2) * ones(n_offset, 1);
x_star(n_offset+1:N+n_offset, 3) = z(2:4:N*nx);
x_star(n_offset+1:N+n_offset, 4) = z(3:4:N*nx);
x_star(n_offset+1:N+n_offset, 5) = z(4:4:N*nx);

%% Plot simulated system
fig = figure(1); 
clf(1);
sim_travel = z(1:nx:N*nx);
sim_pitch  = z(3:nx:N*nx);
hold all;
box  on;
plot(t, (180/pi)*x_star(:, 2), 'LineWidth', 2);
% plot(t, (180/pi)*x_star(:, 4), 'LineWidth', 2);
% plot(t, (180/pi)*x_star(:, 5), 'LineWidth', 1);
plot(t, (180/pi)*u_star(:, 2), 'LineWidth', 2);
plot(t, zeros(2*n_offset+N,1), '--','Color', [0 0 0]);
legend('Optimal travel', 'Optimal pitch reference', 'Location','NorthEast');
line([offsetTime offsetTime],get(gca,'YLim'),'Color','Black','LineWidth',1);
line([offsetTime+N*h offsetTime+N*h],get(gca,'YLim'),'Color','Black','LineWidth',1);
xlim([0 (N+2*n_offset)*h]);
xlabel('Time [s]');
ylabel('Angle [deg]');
title(sprintf('Simulation of system over %d-length horizon', N));
% Plot results
load  ('measurements.mat');
save (sprintf('../../measurements/day3/measurements_q_%d_%d_%d_%d.mat', Q_LQR(1,1), Q_LQR(2,2), Q_LQR(3,3), Q_LQR(4,4)), 'measurements');
% load( sprintf('../../measurements/day3/measurements_q_%d_%d_%d_%d.mat', Q_LQR(1,1), Q_LQR(2,2), Q_LQR(3,3), Q_LQR(4,4)));
t_real = measurements(1,:);
travel = (180/pi)*measurements(2,:);
pitch = (180/pi)*measurements(4,:);
plot(t_real,travel, 'LineWidth', 2,'LineStyle','--');
plot(t_real, pitch, 'LineWidth', 2, 'LineStyle', '--');
legend('Opt travel ref', 'Opt pitch ref','Real Travel', 'Real Pitch');
xlabel('Time [s]');
ylabel('Angle [deg]');
title('Simulated optimal trajectory without feedback')
box  on;

% Set the dimensions of the figure
set(fig, 'units','centimeters');
pos = get(gcf, 'position');
set(gcf, 'position', [pos(1), pos(2), 15, 9]);
