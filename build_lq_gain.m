function [K, A, B, Q, R] = build_lq_gain()

num_states = 8;
num_inputs = 4;

S = 0.5 * ones(num_states, 1);

t_1i_5i = 0.6;
t_3i_5i = 0.3;
t_6i_2i = 0.6;
t_7i_2i = 0.3;

A = eye(num_states);
B = zeros(num_states, num_inputs);

B(3, 1) = -S(3);
B(4, 1) = -S(4);
B(5, 1) =  t_3i_5i * S(3);

B(1, 2) = -S(1);
B(2, 2) = -S(2);
B(5, 2) =  t_1i_5i * S(1);

B(7, 3) = -S(7);
B(8, 3) = -S(8);
B(2, 3) =  t_7i_2i * S(7);

B(5, 4) = -S(5);
B(6, 4) = -S(6);
B(2, 4) =  t_6i_2i * S(6);

lengths = [492.8, 492.8, 492.8, 492.8, ...
           492.8, 492.8, 502.8, 502.8];
x_max = (lengths / 7.5)';

weights = ones(num_states, 1);
weights(2) = 3.0;
weights(5) = 3.0;

Q = diag(weights ./ x_max) * 50;
R = 0.01 * eye(num_inputs);

% Design LQR on the controllable subspace.
H = orth(B);

if size(H, 2) ~= num_inputs
    error('Expected B to have rank %d; got %d.', ...
          num_inputs, size(H, 2));
end

A1 = H' * A * H;
B1 = H' * B;
Q1 = H' * Q * H;

[K1, ~, reduced_poles] = dlqr(A1, B1, Q1, R);
K = K1 * H';

fprintf('rank(B) = %d (out of %d states)\n', rank(B), num_states);
fprintf('K dimensions: %d x %d\n', size(K, 1), size(K, 2));
fprintf('Reduced closed-loop poles:\n');
disp(reduced_poles.');
fprintf('Full closed-loop poles:\n');
disp(eig(A - B * K).');

end
