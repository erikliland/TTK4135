run('../init.m');

% State vector
% x1: travel
% x2: travel rate
% x3: pitch
% x4: pitch rate
% x5: elevation
% x6: elevation rate

% Input vector
% u1: pitch setpoint
% u2: elevation setpoint

global N alpha beta travel_t nx

% Adjustable parameters
x0 = [pi 0 0 0 0 0]';       % Initial state
h  = 0.25;                  % Discretization timestep
N  = 60;                    % Length of horizon
offsetTime = 5;          % Init time at start of simulation
n_offset = offsetTime/h; % Deadzone at start and end (timesteps)
nx = 6;                     % Number of states of system
nu = 2;                     % Number of inputs of system
nz = N*(nx+nu);             % Size of z
Q  = diag([1 0 0 0 0 0]); % State penalty weights
R  = diag([1 1]);           % Input penalty weight

% Non-linear elevation constraint params
alpha    = 0.2;
beta     = 20;
travel_t = 2*pi/3;

% System state and input bounds
pitch_lim = 30*pi/180;
pitch_rate_lim = 30*pi/180;
x_max = [+inf +inf +pitch_lim +pitch_rate_lim +inf +inf]';
x_min = [-inf -inf -pitch_lim -pitch_rate_lim -inf -inf]';
u_max = [+pitch_lim +inf]';
u_min = [-pitch_lim -inf]';

% Continuous-time system matrices
Ac = [0 1     0         0      0         0     ;
      0 0   -K_2        0      0         0     ;
      0 0     0         1      0         0     ;
      0 0 -K_1*K_pp -K_1*K_pd  0         0     ;
      0 0     0         0      0         1     ;
      0 0     0         0  -K_3*K_ep -K_3*K_ed];
  
Bc = [0 0 ; 0 0 ; 0 0 ; K_1*K_pp 0 ; 0 0 ; 0 K_3*K_ep];

% Discrete-time system matrices
A = eye(6) + h * Ac;
B = h * Bc;

% Solve QP
Aeq            = gena2(A, B, N, nx, nu);
Beq            = zeros(N*nx, 1);
Beq(1:nx)      = A*x0;
H              = genq2(Q, R, N, N);
[lb, ub]       = genbegr2(N, N, x_min, x_max, u_min, u_max);
lb(nx*(N-1)+1) = 0;
ub(nx*(N-1)+1) = 0;

f = @(z) z' * H * z;
final_e = alpha*exp(-beta*(pi-travel_t)^2);
final_x = [0 0 0 0 final_e+0.1 0]';
final_u = [0 final_e+0.1]';
z0 = [x0 ; 
      repmat(final_x, N-1, 1);
      repmat(final_u, N, 1)];
  options = optimset('Algorithm','sqp');
z = fmincon(f, z0, [], [], Aeq, Beq, lb, ub, @confun,options);

% LQR
Q_LQR = diag([20 1 1 1 30 10]);
R_LQR = diag([1 1]);
[K, S, E] = dlqr(A,B,Q_LQR,R_LQR);

% Create Simulink inputs
t = (0:N+2*n_offset-1) * h;
u = [z(N*nx+1:nu:nz) z(N*nx+2:nu:nz)];
u_star = zeros(N+2*n_offset, nu+1);
u_star(:, 1) = t;
u_star(n_offset+1:N+n_offset, 2) = u(:,1);
u_star(n_offset+1:N+n_offset, 3) = u(:,2);
x_star = zeros(N+2*n_offset, nx+1);
x_star(:, 1) = t;
x_star(1:n_offset, 2) = pi * ones(n_offset, 1);
x_star(n_offset+1:N+n_offset, 2) = z(1:nx:N*nx);
x_star(N+n_offset+1:N+2*n_offset, 2) = x_star(n_offset+N, 2) * ones(n_offset, 1);
x_star(n_offset+1:N+n_offset, 3) = z(2:nx:N*nx);
x_star(n_offset+1:N+n_offset, 4) = z(3:nx:N*nx);
x_star(n_offset+1:N+n_offset, 5) = z(4:nx:N*nx);
x_star(n_offset+1:N+n_offset, 6) = z(5:nx:N*nx);
x_star(n_offset+1:N+n_offset, 7) = z(6:nx:N*nx);

%% Plot simulated trajectory and input
fig = figure(1); clf(1);
set(gca,'FontSize',11)

subplot(2,1,1);
hold all;
sim_travel = z(1:nx:N*nx);
sim_elev   = z(5:nx:N*nx);
pitch_ref  = z(N*nx+1:nu:N*(nx+nu));
elev_ref   = z(N*nx+2:nu:N*(nx+nu));
plot(t, x_star(:,2)*180/pi, 'LineWidth', 2);
plot(t, u_star(:,2)*180/pi,  'LineWidth', 2);
legend('x_t^*','u_p^*');
xlabel('Time [s]');
ylabel('Angle [deg]');

subplot(2,1,2);
hold all;
c = alpha*exp(-beta*(sim_travel-travel_t).^2);
plot(t, x_star(:,6)*180/pi,   'LineWidth', 2);
plot(t, u_star(:,3)*180/pi,   'LineWidth', 2);
plot(t, [zeros(n_offset,1); c*180/pi; zeros(n_offset,1)], '--', 'LineWidth', 2);
legend('x_e^*', 'u_e^*', 'Constraint');
xlabel('Time [s]');
ylabel('Angle [deg]');

% Plot results
%load ('measurements.mat');
%load ('inputs.mat');
%save (sprintf('../../measurements/day4/measurements_q_%d_%d_%d_%d_%d_%d.mat', Q_LQR(1,1), Q_LQR(2,2), Q_LQR(3,3), Q_LQR(4,4), Q_LQR(5,5), Q_LQR(6,6)),'measurements');
%save (sprintf('../../measurements/day4/inputs_q_%d_%d_%d_%d_%d_%d.mat', Q_LQR(1,1), Q_LQR(2,2), Q_LQR(3,3), Q_LQR(4,4), Q_LQR(5,5), Q_LQR(6,6)),'inputs');
load(sprintf('../../measurements/day4/measurements_q_%d_%d_%d_%d_%d_%d.mat', Q_LQR(1,1), Q_LQR(2,2), Q_LQR(3,3), Q_LQR(4,4), Q_LQR(5,5), Q_LQR(6,6)));
load(sprintf('../../measurements/day4/inputs_q_%d_%d_%d_%d_%d_%d.mat', Q_LQR(1,1), Q_LQR(2,2), Q_LQR(3,3), Q_LQR(4,4), Q_LQR(5,5), Q_LQR(6,6)));
t_real = measurements(1,:);
travel = (180/pi)*measurements(2,:);
elevation = (180/pi)*measurements(6,:);
pitchInput = (180/pi)*inputs(2,:);
elevationInput = (180/pi)*inputs(3,:);

subplot(2,1,1);
hold all;
plot(t_real,travel, 'LineWidth', 2,'LineStyle','--');
plot(t_real, pitchInput, 'LineWidth', 2, 'LineStyle', '--');
legend('x_t^*', 'u_p^*','x_t','u_p');
title('Simulated optimal trajectory with feedback','FontSize',14,'FontWeight','normal');
line([offsetTime offsetTime],get(gca,'YLim'),'Color','Black','LineWidth',1);
line([offsetTime+N*h offsetTime+N*h],get(gca,'YLim'),'Color','Black','LineWidth',1);
xlim([4 (N+2*n_offset)*h]);
ylim([-50 210]);

subplot(2,1,2);
hold all;
plot(t_real,elevation, 'LineWidth', 2,'LineStyle','--');
legend('x_e^*','u_e^*','Constraint','x_e');
line([offsetTime offsetTime],get(gca,'YLim'),'Color','Black','LineWidth',1);
line([offsetTime+N*h offsetTime+N*h],get(gca,'YLim'),'Color','Black','LineWidth',1);
xlim([4 (N+2*n_offset)*h]);
ylim([-5 14]);

% Set the dimensions of the figure
set(fig, 'units','centimeters');
pos = get(gcf, 'position');
set(gcf, 'position', [pos(1), pos(2), 15, 12]);

%saveas(fig, sprintf('../../figures/day4_cl/plot_q_%d_%d_%d_%d_%d_%d', Q_LQR(1,1), Q_LQR(2,2), Q_LQR(3,3), Q_LQR(4,4), Q_LQR(5,5), Q_LQR(6,6)),'epsc');
