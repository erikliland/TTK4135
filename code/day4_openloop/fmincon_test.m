f = @(z) z(1)^2 + z(2)^2;
c = @(z) [-z(2) + exp(-z(1)^2) ;
          z(1) - 2            ];
nonlcon = @(z) [c(z) [0 ; 0]];
z0 = [1 3];
z = fmincon(f, z0, [], [], [], [], [], [], nonlcon);