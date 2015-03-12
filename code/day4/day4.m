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

% Adjustable parameters
x0 = [pi 0 0 0 0 0]';       % Initial state
h  = 0.25;                  % Discretization timestep
N  = 40;                    % Length of horizon
nx = 6;                     % Number of states of system
nu = 2;                     % Number of inputs of system
Q  = diag([1 0 0.1 0 0 0]); % State penalty weights
R  = diag([1 1]);           % Input penalty weight

% Non-linear elevation constraint params
alpha    = 0.2;
beta     = 20;
travel_t = 2*pi/3;

% System state and input bounds
pitch_lim = 30*pi/180;
x_max = [+inf +inf +pitch_lim +inf +inf +inf]';
x_min = [-inf -inf -pitch_lim -inf -inf -inf]';
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
final_e = alpha*exp(-beta*(-travel_t)^2);
final_x = [0 0 0 0 0 0]';
final_u = [0 0]';
z0 = [x0 ; 
      repmat(final_x, N-1, 1);
      repmat(final_u, N, 1)];
z = fmincon(f, z0, [], [], Aeq, Beq);
% z = quadprog(H, [], [], [], Aeq, Beq, lb, ub);

%% Plot simulated trajectory and input
time       = (0:N-1)*h;
sim_travel = z(1:nx:N*nx);
sim_elev   = z(5:nx:N*nx);
pitch_ref  = z(N*nx+1:nu:N*(nx+nu));
elev_ref   = z(N*nx+2:nu:N*(nx+nu));
figure(1); clf(1);
hold('all');
axis('square');
box('on');
    plot(time, sim_travel, 'LineWidth', 2);
    plot(time, pitch_ref,  'LineWidth', 2);
    legend('Travel', 'Pitch setpoint');
    xlabel('Time [s]');
    ylabel('Angle [deg]');
    
%     plot(time, sim_elev,   'LineWidth', 2);
%     plot(time, elev_ref,   'LineWidth', 2);
%     legend('Elevation', 'Elevation setpoint');
%     xlabel('Time [s]');
%     ylabel('Angle [deg]');

%     plot(sim_travel, sim_elev, 'LineWidth', 2);
%     xlabel('Travel [deg]');
%     ylabel('Elevation [deg]');