function [K, A, B, Q, R] = build_lq_gain(C)
if nargin < 1
    C = 90; 
end

num_states = 8;
num_inputs = 4;

S = 0.5 * ones(num_states, 1);

t_1i_5i = 0.6;
t_3i_5i = 0.3;
t_6i_2i = 0.6;
t_7i_2i = 0.3;

A_raw = eye(num_states);
B = zeros(num_states, num_inputs);

B(3, 1) = -S(3);
B(4, 1) = -S(4);
B(5, 1) = +t_3i_5i * S(3);

B(1, 2) = -S(1);
B(2, 2) = -S(2);
B(5, 2) = +t_1i_5i * S(1);

B(7, 3) = -S(7);
B(8, 3) = -S(8);
B(2, 3) = +t_7i_2i * S(7);

B(5, 4) = -S(5);
B(6, 4) = -S(6);
B(2, 4) = +t_6i_2i * S(6);

lengths = [492.8, 492.8, 492.8, 492.8, 492.8, 492.8, 502.8, 502.8];
x_max = (lengths / 7.5)'; 

weights = ones(8, 1);
weights(2) = 3.0; 
weights(5) = 3.0; 

%  weighting matrices 
Q = diag(weights ./ x_max) * 50;
R = 0.01 * eye(num_inputs);

alpha = 0.985;
A = alpha * A_raw;
[K, ~, ~] = dlqr(A, B, Q, R);

A = A_raw;

fprintf('>> LQR gain matrix successfully computed (Dimensions: %dx%d).\n', size(K, 1), size(K, 2));
end
