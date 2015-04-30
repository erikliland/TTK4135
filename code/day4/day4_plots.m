run('../init.m');
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
z0 = [x0;repmat(final_x, N-1, 1);repmat(final_u, N, 1)];
options = optimset('Algorithm','sqp');
z = fmincon(f, z0, [], [], Aeq, Beq, lb, ub, @confun,options);
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

m_1_1_1_1_1_1 = load('../../measurements/day4/measurements_q_1_1_1_1_1_1.mat');
m_1_1_40_1_1_1= load('../../measurements/day4/measurements_q_1_1_40_1_1_1.mat');
m_20_1_1_1_20_1=load('../../measurements/day4/measurements_q_20_1_1_1_20_1.mat');
m_20_1_1_1_30_10=load('../../measurements/day4/measurements_q_20_1_1_1_30_10.mat');

%% Plot simulated system
fig = figure(1); clf(1);box  on; hold all; 
set(gca,'FontSize',12); 
xlabel('Time [s]');ylabel('Angle [deg]');
title('Comparison of different Q matrixes','FontSize',14,'FontWeight','normal');
plot(t, (180/pi)*x_star(:,2),'LineWidth', 2,'LineStyle',':');
plot(m_1_1_1_1_1_1.measurements(1,:),180/pi*m_1_1_1_1_1_1.measurements(2,:),'LineWidth',2,'LineStyle','-');
plot(m_1_1_40_1_1_1.measurements(1,:),180/pi*m_1_1_40_1_1_1.measurements(2,:)  ,'LineWidth',2,'LineStyle','-');
plot(m_20_1_1_1_20_1.measurements(1,:),180/pi*m_20_1_1_1_20_1.measurements(2,:),'LineWidth',2,'LineStyle','-');
plot(m_20_1_1_1_30_10.measurements(1,:),180/pi*m_20_1_1_1_30_10.measurements(2,:),'LineWidth',2,'LineStyle','-');
legend('Opt travel ref', 'diag(1 1 1 1 1 1)','diag(1 1 40 1 1 1)', 'diag(20 1 1 1 20 1)','diag(20 1 1 1 30 10)','Location','North');
plot(t, zeros(2*n_offset+N,1), '-','Color', [0.6 0.6 0.6]);
line([offsetTime offsetTime],get(gca,'YLim'),'Color','Black','LineWidth',1);
line([offsetTime+N*h offsetTime+N*h],get(gca,'YLim'),'Color','Black','LineWidth',1);
xlim([4 (N+2*n_offset)*h]);
ylim([-15 200]);
set(fig, 'units','centimeters');
pos = get(gcf, 'position');
set(gcf, 'position', [pos(1), pos(2), 15, 9]);