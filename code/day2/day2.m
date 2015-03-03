run('../init.m');

% Adjustable parameters
x0 = [pi 0 0 0]'; % Initial state
Q = eye(4);       % State penalty weights
R  = 1;           % Input penalty weight
h  = 0.25;        % Discretization timestep
N  = 100;         % Length of horizon
nx = 4;           % Number of states of system
nu = 1;           % Number of inputs of system
n_offset = 5/h;   % Deadzone at start and end (timesteps)

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
% A = eye(4) + h * Ac;
% B = h * Bc;
M = expm(h*[Ac Bc ; 0 0 0 0 0]);
A = M(1:4, 1:4);
B = M(1:4, 5);

% Generate equality constraints matrix
Aeq = gena2(A, B, N, nx, nu);

% Generate righthand side of equality constraints
Beq       = zeros(N*nx, 1);
Beq(1:nx) = A*x0;

% Generate quadratic objective matrix
H = genq2(Q, R, N, N, nu);

% Solve QP
[lb, ub] = genbegr2(N, N, x_min, x_max, u_min, u_max);
lb(nx*(N-1)+1) = 0;
ub(nx*(N-1)+1) = 0;
f = zeros(1, n);
z = quadprog(H, f, [], [], Aeq, Beq, lb, ub);
u = z(N*nx+1:n);

% Plot simulated system
figure(1); clf(1);
sim_travel = z(1:4:N*nx);
sim_pitch  = z(3:4:N*nx);
time = (0:N-1+2*n_offset)*h;
hold all;
plot(time, (180/pi)*[ones(n_offset,1)*pi ; sim_travel ; zeros(n_offset,1)], 'LineWidth', 2);
plot(time, (180/pi)*[zeros(n_offset,1) ; sim_pitch ; zeros(n_offset,1)], 'LineWidth', 2);
hx = graph2d.constantline(5,'LineStyle', '--','Color','black', 'LineWidth',2);
changedependvar(hx,'x');
legend('Travel', 'Pitch');
axis square;
box  on;
xlim([0 (N+2*n_offset)*h]);
xlabel('Time [s]');
ylabel('Agle [deg]');
title(sprintf('Simulation of system over %d-length horizon', N));


t = (0:N+2*n_offset-1) * h;

pitch_input = zeros(N+2*n_offset, 2);
pitch_input(:, 1) = t;
pitch_input(n_offset+1:N+n_offset, 2) = u;

elev_input = zeros(N+2*n_offset,2);
elev_input(:,1)=t;
elev_input(end,2) = -5*(pi/180);

%% Plot results
load ('measurements.mat');
t = measurements(1,:);
travel = (180/pi)*measurements(2,:);
pitch = (180/pi)*measurements(4,:);
plot(t,travel, 'LineWidth', 2,'LineStyle','--');
plot(t, pitch, 'LineWidth', 2, 'LineStyle', '--');
legend('Sim Travel', 'Sim Pitch','Real Travel', 'Real Pitch');
xlabel('Time [s]');
ylabel('Agle [deg]');
title('Simulated optimal trajectory without feedback');
axis square;
box  on;
