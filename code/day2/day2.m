run('../init.m');

h = 0.25; % timestep
N = 100;  % number of samples

% Continuous time matrices
Ac = [0 1 0 0 ; 0 0 -K_2 0 ; 0 0 0 1 ; 0 0 -K_1*K_pp -K_1*K_pd];
Bc = [0 ; 0 ; 0 ; K_1*K_pp];

% Discrete time matrices (forward Euler difference approx)
A = eye(4) + h * Ac;
B = h * Bc;
%Upper and lower bounds. First row is states, second row is inputs
% ub = [Inf(1, N)';30*pi/180 * ones(1,N)'];
% lb = [-Inf(1,N)';-30*pi/180 * ones(1,N)'];
%ub(2,end)=0; %Last output should be zero
%lb(2,end)=0; %Last output should be zero

x0 = [pi 0 0 0];
% H = kron(eye(N),2*diag([1 0 0 0]));
q = 0.1;

%[x, fval, exitflag, output, lambda] = .../../help/quadprog(H,[],[],[],Aeq,Beq,lb,ub,x0);

t = 0:h:N*h-h;
u = zeros(1, N);
u(51:N) = ones(1, 50) * 0.5;

pitch_input = zeros(N, 2);
pitch_input(:, 1) = t;
pitch_input(:, 2) = u;
