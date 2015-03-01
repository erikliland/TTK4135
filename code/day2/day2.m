run('../init.m');

% Adjustable parameters
x0 = [pi 0 0 0]'; % Initial state
Q = eye(4);       % State penalty weights
R  = 1;           % Input penalty weight
h  = 0.25;        % Discretization timestep
N  = 100;         % Length of horizon
nx = 4;           % Number of states of system
nu = 1;           % Number of inputs of system

% System state and input bounds
pitch_lim = 30*pi/180;
x_max = [+inf +inf +pitch_lim +inf]';
x_min = [-inf -inf -pitch_lim -inf]';
u_max = +pitch_lim;
u_min = -pitch_lim;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

n  = N * (nx + nu); % Length of manipulation variable vector

% Continuous-time system matrices
Ac = [0 1 0 0 ; 0 0 -K_2 0 ; 0 0 0 1 ; 0 0 -K_1*K_pp -K_1*K_pd];
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
f = zeros(1, n);
z = quadprog(H, f, [], [], Aeq, Beq, lb, ub);
u = z(N*nx+1:n);

% Plot simulated system
sim_travel = z(1:4:N*nx);
sim_pitch  = z(3:4:N*nx);
hold all;
time = (0:N-1)*h;
plot(time, (180/pi)*sim_travel, 'LineWidth', 2);
plot(time, (180/pi)*sim_pitch, 'LineWidth', 2);
legend('Travel', 'Pitch');
axis square;
box  on;
grid on;
xlim([0 N*h]);
xlabel('time (seconds)');
ylabel('angle (degrees)');
title(sprintf('Simulation of system over %d-length horizon', N));

% t = 0:h:N*h-h;
% u = zeros(1, N);
% u(51:N) = ones(1, 50) * 0.5;
% 
% pitch_input = zeros(N, 2);
% pitch_input(:, 1) = t;
% pitch_input(:, 2) = u;
