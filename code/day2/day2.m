run('../init.m');

% Adjustable parameters
x0 = [pi 0 0 0]';        % Initial state
R  = 1;                  % Input penalty weight
h  = 0.25;               % Discretization timestep
N  = 100;                % Length of horizon
nx = 4;                  % Number of states of system
nu = 1;                  % Number of inputs of system
offsetTime = 5;          % Init time at start of simulation
n_offset = offsetTime/h; % Deadzone at start and end (timesteps)
Q = eye(nx);             % State penalty weights
Q(2,2) = 0;              % Free travel rate 
Q(4,4) = 0;              % Free pitch rate

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
      0 0 -K_1*K_pd -K_1*K_pd];
  
Bc = [0 ; 0 ; 0 ; K_1*K_pp];

% Discrete-time system matrices
A = eye(4) + h * Ac;
B = h * Bc;
%M = expm(h*[Ac Bc ; 0 0 0 0 0]);
%A = M(1:4, 1:4);
%B = M(1:4, 5);

% Generate equality constraints matrix
Aeq = gena2(A, B, N, nx, nu);

% Generate righthand side of equality constraints
Beq       = zeros(N*nx, 1)';
Beq(1:nx) = A*x0;

% Generate quadratic objective matrix
H = genq2(Q, R, N, N, nu);

% Solve QP
[lb, ub] = genbegr2(N, N, x_min, x_max, u_min, u_max);
%lb(nx*(N-1)+1) = 0; %Limit last state
%ub(nx*(N-1)+1) = 0; %Limit last state
%lb((nx+nu)*N)  = 0; %Limit last input
%ub((nx+nu)*N)  = 0; %Limit last input
f = zeros(1, n);
z = quadprog(H, f, [], [], Aeq, Beq, lb, ub);
u = z(N*nx+1:n);

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

t = (0:N+2*n_offset-1) * h;
pitch_input = zeros(N+2*n_offset, 2);
pitch_input(:, 1) = t;
pitch_input(n_offset+1:N+n_offset, 2) = u;


x1 = [x0(1);z(1:nx:N*nx)];
x2 = [x0(2);z(2:nx:N*nx)];
x3 = [x0(3);z(3:nx:N*nx)];
x4 = [x0(4);z(4:nx:N*nx)];
x1  = [pi*ones(n_offset-1,1); x1; zeros(n_offset,1)];
x2  = [zeros(n_offset-1,1); x2; zeros(n_offset,1)];
x3  = [zeros(n_offset-1,1); x3; zeros(n_offset,1)];
x4  = [zeros(n_offset-1,1); x4; zeros(n_offset,1)];

%Discrete plot
figure(2);
subplot(511);
stairs(t,pitch_input(:,2)),grid
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

%% Plot results
% load ('measurements.mat');
% t = measurements(1,:);
% travel = (180/pi)*measurements(2,:);
% pitch = (180/pi)*measurements(4,:);
% plot(t,travel, 'LineWidth', 2,'LineStyle','--');
% plot(t, pitch, 'LineWidth', 2, 'LineStyle', '--');
% legend('Sim Travel', 'Sim Pitch','Real Travel', 'Real Pitch');
% xlabel('Time [s]');
% ylabel('Agle [deg]');
% title('Simulated optimal trajectory without feedback');
% axis square;
% box  on;
