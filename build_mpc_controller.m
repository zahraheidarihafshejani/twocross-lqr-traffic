function mpc_obj = build_mpc_controller(B, Q, R)

mpc_obj.N = 5;

% Mapping green adjustments to 4 input channels
D = [ 1  0;
     -1  0;
      0  1;
      0 -1];

mpc_obj.Bd = B * D;

% Precompute QP matrices offline
G = kron(tril(ones(mpc_obj.N)), mpc_obj.Bd);
Qbar = kron(eye(mpc_obj.N), Q);
Rbar = kron(eye(mpc_obj.N), D' * R * D);

mpc_obj.H = 2 * (G' * Qbar * G + Rbar);
mpc_obj.F = 2 * G' * Qbar;

mpc_obj.lb = -12 * ones(2 * mpc_obj.N, 1);
mpc_obj.ub =  12 * ones(2 * mpc_obj.N, 1);
mpc_obj.options = optimoptions('quadprog', 'Display', 'off');

% Attach solver method directly to controller object
mpc_obj.solve = @(x, drift, cyc) solve_internal(x, drift, mpc_obj, cyc);

end

function delta = solve_internal(x, drift, cfg, cyc)
    x_base = kron(ones(cfg.N, 1), x) + kron((1:cfg.N)', drift);
    
    [z, ~, exitflag] = quadprog(...
        cfg.H, cfg.F * x_base, ...
        [], [], [], [], cfg.lb, cfg.ub, [], cfg.options);
    
    if isempty(z) || exitflag <= 0
        warning('MPC QP failed at cycle %d; fallback to delta=0.', cyc);
        delta = zeros(2, 1);
    else
        delta = z(1:2);
    end
end
