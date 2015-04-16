function [c, ceq] = confun(z)
global N nx alpha beta travel_t
% Nonlinear inequality constraints
c = zeros(N, 1);
for k=1:N
    travel = z(1 + (k-1)*nx);
    elev   = z(5 + (k-1)*nx);
    c(k) = alpha * exp(-beta*(travel - travel_t)^2) - elev;
end
% Nonlinear equality constraints
ceq = [];