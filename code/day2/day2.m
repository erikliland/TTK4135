run('../init.m');

h = 0.25; % timestep
N = 100;  % number of samples
q = 0.1;

% Continuous time matrices
Ac = [0 1 0 0 ; 0 0 -K_2 0 ; 0 0 0 1 ; 0 0 -K_1*K_pp -K_1*K_pd];
Bc = [0 ; 0 ; 0 ; K_1*K_pp];

% Discrete time matrices (forward Euler difference approx)
A = eye(4) + h * Ac;
B = h * Bc;

%Upper and lower bounds. First row is states, second row is inputs

ubx = zeros(1, 4 * N);
ubu = zeros(1, N);
lbx = zeros(1, 4 * N);
lbu = zeros(1, N);

j = 1;
for i=1:N
    r = [Inf(1, 1) Inf(1, 1) 30*pi/180 Inf(1, 1)];
    ubx(j:j+3) = r;
    lbx(j:j+3) = -r;
    j = j + 4;
end

ubu = ones(1, N) * 30 * pi / 180;
lbu = -ones(1, N) * 30 * pi / 180;

ub = [ubx ubu];
lb = [lbx lbu];

Aeq = gena2(A, B, 100, 4, 1);
Beq = zeros(4 * N, 1);

Q1 = [1 0 0 0 ; 0 0 0 0 ; 0 0 0 0 ; 0 0 0 0];
P1 = [q];
H = genq2(Q1, P1, N, N, 1);

f = zeros(1, 5 * N);
x0 = [pi ; 0 ; 0 ; 0];
[X, fval, exitflag, output, lambda] = quadprog(H, f, [], [], Aeq, Beq, lb, ub, x0);

t = 0:h:N*h-h;
u = zeros(1, N);
u(51:N) = ones(1, 50) * 0.5;

pitch_input = zeros(N, 2);
pitch_input(:, 1) = t;
pitch_input(:, 2) = u;
